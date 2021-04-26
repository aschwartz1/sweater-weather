# Sweater Weather?
_Completed as the [final project](https://backend.turing.edu/module3/projects/sweater_weather/) for Module 3 of [The Turing School's](https://turing.edu) curriculum._

The Back End API portion of a proposed SOA application to plan road trips. This app will allow users to see the current weather as well as the forecasted weather at the destination.

# Contents
1. [Endpoints](#endpoints)
    - [Weather Data for a City](#weather-data-for-a-city)
    - [Background Image for a City](#background-image-for-a-city)
    - [User Creation](#user-creation)
    - [User Log In](#user-log-in)

# Endpoints
## Weather Data for a City
- Parameters
  - `location` **required**
  - format: `<city>,<2 letter state code>`
- General Response Info
  - Returns top-level `data` element with main payload nested in `attributes`
  - `attributes`
    - `current_weather` - hash containing current weather snapshot. See below for exact keys.
    - `daily_weather` - array of 5 days of daily weather snapshots. See below for exact keys.
    - `hourly_weather` - array of 8 hours of hourly weather snapshots. See below for exact keys.

>```
> GET /api/v1/forecast?location=denver,co
> Content-Type: application/json
> Accept: application/json
>```
>```json
>{
>  "data": {
>    "id": null,
>    "type": "forecast",
>    "attributes": {
>      "current_weather": {
>        "datetime": "2021-04-24 16:13:33 -0600",
>        "sunrise": "2021-04-24 06:08:57 -0600",
>        "sunset": "2021-04-24 19:46:43 -0600",
>        "temperature": 64.8,
>        "feels_like": 62.2,
>        "humidity": 26,
>        "uvi": 2.96,
>        "visibility": 10000,
>        "conditions": "overcast clouds",
>        "icon": "04d"
>      },
>      "daily_weather": [
>        {
>          "date": "2021-04-25",
>          "sunrise": "2021-04-25 06:07:37 -0600",
>          "sunset": "2021-04-25 19:47:44 -0600",
>          "max_temp": 75.81,
>          "min_temp": 47.14,
>          "conditions": "scattered clouds",
>          "icon": "03d"
>        },
>        {
>          "date": "2021-04-26",
>          "sunrise": "2021-04-26 06:06:18 -0600",
>          "sunset": "2021-04-26 19:48:45 -0600",
>          "max_temp": 75.56,
>          "min_temp": 51.35,
>          "conditions": "broken clouds",
>          "icon": "04d"
>        },
>        ...
>      ],
>      "hourly_weather": [
>        {
>          "time": "17:00:00",
>          "temperature": 65.05,
>          "conditions": "overcast clouds",
>          "icon": "04d"
>        },
>        {
>          "time": "18:00:00",
>          "temperature": 64.98,
>          "conditions": "overcast clouds",
>          "icon": "04d"
>        },
>        ...
>      ]
>    }
>  }
>}
>```


## Background Image for a City
- Note
  - The background image may not correspond exactly to a city, as it is dependent upon what results come back from [Unsplash](https://unsplash.com?utm_source=sweater_weather&utm_medium=referral).
- Parameters
  - `location` **required**
  - format: `<city>,<2 letter state code>`
- General Response Info
  - Returns top-level `data` element with main payload nested in `attributes`
  - `attributes`
    - `image` - hash containing image info, including `urls`. See below for exact keys.
    - `credit` - hash containing credit info for author and [Unsplash](https://unsplash.com?utm_source=sweater_weather&utm_medium=referral)

>```
> GET /api/v1/forecast?location=denver,co
> Content-Type: application/json
> Accept: application/json
>```
>```json
>{
>  "data": {
>    "id": nil,
>    "type": "image",
>    "attributes": {
>      "image": {
>        "width": 444,
>        "height": 222,
>        "urls": {
>          "raw": "https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral",
>          "full": "https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral",
>          "regular": "https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral",
>          "small": "https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral",
>          "thumb": "https://unsplash.com/photo/path?utm_source=sweater_weather&utm_medium=referral"
>        }
>      },
>      "credit": {
>        "author": {
>          "name": "Bob Trufont",
>          "url": "https://unsplash.com/@bobtrufont?utm_source=sweater_weather&utm_medium=referral"
>        },
>        "host": {
>          "name": "Unsplash",
>          "url": "https://unsplash.com?utm_source=sweater_weather&utm_medium=referral"
>        }
>      }
>    }
>  }
>}
>```

## User Creation
- Body Data
  - `email` **required**
  - `password` **required**
  - `password_confirmation` **required**
- Success Response Info
  - `201 Created`
  - Returns top-level `data` element with main payload nested in `attributes`
  - `id` will be the id for the created user
  - `attributes`
    - `email` - the email sent with the request, normalized to lowercase
    - `api_key` - a unique api_key for the user

>```
>POST /api/v1/users
>Content-Type: application/json
>Accept: application/json
>
>{
>  "email": "whatever@example.com",
>  "password": "password",
>  "password_confirmation": "password"
>}
>```
>```json
>{
>  "data": {
>    "id": "1",
>    "type": "users",
>    "attributes": {
>      "email": "foo@example.com",
>      "api_key": "EXAMPLE_KEY"
>    }
>  }
>}
>```

- Failure Response Info
  - Possible error codes:
    - `400 Bad Request`, if the request sent no body data
    - `422 Unprocessable Entity`, if any parameter is invalid (including if password & confirmation don't match)
  - Returns top-level `data` element which will ALWAYS be an array
    - `id` will be null
    - `attributes`
      - `message` - A message about the error

>```json
>{
>  "data": [{
>    "id": null,
>    "type": "users",
>    "attributes": {
>      "message": "Email is invalid",
>    },
>    ...
>  }]
>}
>```

## User Log In
- Body Data
  - `email` **required**
  - `password` **required**
- Success Response Info
  - `200 OK`
  - Returns top-level `data` element with main payload nested in `attributes`
  - `id` will be the id for the created user
  - `attributes`
    - `email` - the email sent with the request, normalized to lowercase
    - `api_key` - a unique api_key for the user

>```
>POST /api/v1/sessions
>Content-Type: application/json
>Accept: application/json
>
>{
>  "email": "whatever@example.com",
>  "password": "password"
>}
>```
>```json
>{
>  "data": {
>    "id": "1",
>    "type": "users",
>    "attributes": {
>      "email": "foo@example.com",
>      "api_key": "EXAMPLE_KEY"
>    }
>  }
>}
>```

- Failure Response Info
  - Possible error codes:
    - `400 Bad Request`, if the request sent no body data
    - `401 Unauthorized`, if any credential is invalid
  - Returns top-level `data` element which will ALWAYS be an array
    - `id` will be null
    - `attributes`
      - `message` - A message about the error

>```json
>{
>  "data": [{
>    "id": null,
>    "type": "users",
>    "attributes": {
>      "message": "Invalid credentials",
>  }]
>}
>```
