"""Experiment backend of jwl user authorization."""
from datetime import datetime, timedelta
from typing import Union

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import jwt, JWTError
from passlib.context import CryptContext
from pydantic import BaseModel
from secrect_strs import JWT_KEY, NONCE_PEPPER

# to get a string like this run:
# openssl rand -hex 32
# SECRET_KEY = '09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7'
ALGORITHM = 'HS256'
ACCESS_TOKEN_EXPIRE_MINUTES = 30


# User database
fake_users_db = {
    'johndoe': {
        'username': 'johndoe',
        'full_name': 'John Doe',
        'email': 'johndoe@example.com',
        'hashed_password': '$2b$12$FQaU2NuK243lzzwhZy8ml.tmI6jG/eWD0CEX4jO3BE0piS9vqcREu',
        'disabled': False,
    },
    'kumkee': {
        'username': 'kumkee',
        'full_name': 'Kumkee Leung',
        'email': 'jun@kumkee.net',
        'hashed_password': '$2b$12$EZhC81O8CnZtId1FxlC97.9.LgraqRqqjCCSF2/pcB25edq02rJKK',
        'disabled': False,
    },
}


origins = [
    'http://localhost:8000',  # Elm reactor
    'http://localhost', # Compiled js
]


class Token(BaseModel):
    """Define a Pydantic Model that will be used in the token endpoint for the response."""

    access_token: str
    token_type: str


class TokenData(BaseModel):
    """Token as a Pydantic Model."""

    username: Union[str, None] = None


class User(BaseModel):
    """Use Pydantic to create a user model."""

    username: str
    email: Union[str, None] = None
    full_name: Union[str, None] = None
    disabled: Union[bool, None] = None


class UserInDB(User):
    """Adding hashed_password to the user model."""

    hashed_password: str


# Setting up passlib
pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')

# create an instance of the OAuth2PasswordBearer class we pass in the tokenUrl
# parameter. This parameter contains the URL that the client (the frontend
# running in the user's browser) will use to send the username and password in
# order to get a token.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl='token')

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)


def verify_password(plain_password, hashed_password):
    """Verify if a received password matches the hash stored."""
    return pwd_context.verify(NONCE_PEPPER + plain_password, hashed_password)


def get_password_hash(password):
    """Hash a password coming from the user."""
    return pwd_context.hash(NONCE_PEPPER + password)


def get_user(db, username: str):
    """Return a user model."""
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)


def authenticate_user(fake_db, username: str, password: str):
    """Authenticate and return a user."""
    user = get_user(fake_db, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


def create_access_token(
    data: dict, expires_delta: Union[timedelta, None] = None
):
    """Generate a new access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({'exp': expire})
    encoded_jwt = jwt.encode(to_encode, JWT_KEY, algorithm=ALGORITHM)
    return encoded_jwt


async def get_current_user(token: str = Depends(oauth2_scheme)):
    """Decode the received token, verify it, and return the current user."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail='Could not validate credentials',
        headers={'WWW-Authenticate': 'Bearer'},
    )
    try:
        payload = jwt.decode(token, JWT_KEY, algorithms=[ALGORITHM])
        username: str = str(payload.get('sub'))
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(fake_users_db, username=str(token_data.username))
    if user is None:
        raise credentials_exception
    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user),
):
    """Check and return if a user is active."""
    if current_user.disabled:
        raise HTTPException(status_code=400, detail='Inactive user')
    return current_user


@app.post('/token', response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
):
    """Create a timedelta with the expiration time of the token."""
    """Create a real JWT access token and return it."""
    """Use Auth2PasswordRequestForm as a dependency with Depends in the path
    operation for /token"""
    user = authenticate_user(
        fake_users_db, form_data.username, form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail='Incorrect username or password',
            headers={'WWW-Authenticate': 'Bearer'},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={'sub': user.username}, expires_delta=access_token_expires
    )
    return {'access_token': access_token, 'token_type': 'bearer'}


@app.get('/users/me/', response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    """Path to get user model."""
    return current_user


@app.get('/users/me/items/')
async def read_own_items(
    current_user: User = Depends(get_current_active_user),
):
    """Path to get user items."""
    return [{'item_id': 'Foo', 'owner': current_user.username}]
