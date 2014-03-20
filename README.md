### Oraclocat [![Build Status](https://travis-ci.org/Absolventa/oraclocat.png?branch=master)](https://travis-ci.org/Absolventa/oraclocat)

If you don't know who's gonna merge your Pull Request - Oraclocat knows!


## Installation

### Github Application

Oraclocat needs a Github Application for its authentication system to work: [register a Github application here](https://github.com/settings/applications/new). The authorization callback URL must point to `http(s)://yourdomain/callback`.

You may want to create a seperate app for your development box and define `http://localhost:9292/callback` as the auth callback.

Copy `.env-sample` to `.env` and put your **Client Id** and **Client Secret** in there. Do **not** put the file under version control (it's in .gitignore).

### Running the App

`rackup config.ru` will launch the app at `localhost:9292`.
