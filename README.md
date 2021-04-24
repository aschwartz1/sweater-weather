# Sweater Weather?
_Completed as the [final project](https://backend.turing.edu/module3/projects/sweater_weather/) for Module 3 of [The Turing School's](https://turing.edu) curriculum._

The Back End API portion of a proposed SOA application to plan road trips. This app will allow users to see the current weather as well as the forecasted weather at the destination.

# Contents
1. [Endpoints](#endpoints)
  - [Weather Data for a City](#weather-data-for-a-city)

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
