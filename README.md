# jwtelm

## Overview

`jwtelm` is an example code for user authentication and authorization using JWT (JSON Web Tokens). The backend is built with FastAPI, a modern web framework for building APIs with Python. The frontend is built with Elm, a functional programming language that compiles to JavaScript with no runtime errors.

## Features

- User login
- [JWT](https://jwt.io/)-based authentication and authorization
- Frontend built with [Elm](https://elm-lang.org/)
- Backend built with [FastAPI](https://fastapi.tiangolo.com/) (backend code is based on [this tutorial](https://fastapi.tiangolo.com/tutorial/security/oauth2-jwt/))

## Getting started

To experiment with `jwtelm`, clone this repository to your local machine:

```git clone https://github.com/kumkee/jwtelm.git```


### Backend

1. Navigate to the `backend/` directory.
2. Create a new virtual environment with Python 3.9 and activate it.
3. Install the required packages with `pip install -r requirements.txt`.
4. Add your frontend url(s) to the CORS [`origins` list](https://github.com/kumkee/jwtelm/blob/741ddf62b288c2510e30fecc3f4649a2084353be/backend/main.py#L39) in `backend/main.py`. 
5. Add a file named `secrect_strs.py` in the `backend` directory with your own secret keys. For example:

```
"""Secrets are kept here."""
JWT_KEY = 'my_secret_key'

NONCE_PEPPER = 'my_nonce_pepper'
```
   - The content of `backen/secrect_strs.py` in the live demo is
```
"""Secrects are kept here."""
JWT_KEY = 'c1d1f32fbb59638db394c06566f84dd645fb4dd0fbe171bdcfa458651b0be47e'

NONCE_PEPPER = 'qc4L1PeK2suXpHt9UyjfTJhOfFrjmvvjhdmAaFJ2cd6Vvnyw3iwOOkw='
```


  - Note that this need to be changed for your own project.

6. Run the backend server with `uvicorn main:app --port 8001`.

  - The backend server should now be running at `http://localhost:8001`.

### Frontend

1. Navigate to the `frontend/` directory.
2. Change [`baseUrl`](https://github.com/kumkee/jwtelm/blob/main/frontend/src/Main.elm#L24) in `frontend/src/Main.elm` to your backend url.
2. Build the Elm app for production by running `make`.
3. Serve the compiled Elm app by running `python -m http.server 8000` in `frontend/build/.
4. Alternatively, you can run `elm reactor` under `frontend/` to see the result of the code instantly.

- Note that `make` is for production and `elm reactor` is for reviewing.

- The frontend should now be accessible at `http://localhost:8000`.


## Demo

You can try out a live demo of `jwtelm` at https://kumkee.github.io/jwtelm/. The backend of the live demo is hosted on [Deta Space](https://deta.space/). Login credentials for the demo are
1. `johndoe` with password "secret" or
2. `kumkee` with password "0123456789" 

## Contributing

If you want to contribute to `jwtelm`, you're welcome to submit a pull request. Please make sure to follow the [code of conduct](CODE_OF_CONDUCT.md) and the [contribution guidelines](CONTRIBUTING.md).

## License

`jwtelm` is licensed under the MIT license. See [LICENSE](LICENSE) for more information.

## Conclusion

Demo live page: https://kumkee.github.io/jwtelm/

Please remember to modify `backend/secrect_strs.py` and `origins` in `backend/main.py` for your own project.

---

README generated with the assistance of [ChatGPT](https://github.com/Chandrahas-Tripathi/ChatGPT), a language model developed by OpenAI.

