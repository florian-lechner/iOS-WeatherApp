# Part 2

## Appendix

### Rough Design Part 1
Search
(Search bar)

Once Location is searched:

Geo Info
(Lat, Long)
(sunrise time, sunset time)
(timezone offset)

Weather: (description)
(temp (low, high), feels like)
(cloud coverage)
(wind speed, direction)
(percipation, air pressure)

Air Quality: (description)
(NO, PM10)
(O3, NH3)
(NO2, PM2.5)
(CO, SO2)
(Legend that shows "(unit: μg/m3)")

5 Day Forecast
(Today, (Low temp, High temp))
(Weekday, (Low temp, High temp))
(Weekday, (Low temp, High temp))
(Weekday, (Low temp, High temp))
(Weekday, (Low temp, High temp))
(Weekday, (Low temp, High temp))




### Data Structures:

For Lat / Lon: https://openweathermap.org/api/geocoding-api


API Respond data example:


# Weather API

`https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}`


```json
                          

{
  "coord": {
    "lon": 10.99,
    "lat": 44.34
  },
  "weather": [
    {
      "id": 501,
      "main": "Rain",
      "description": "moderate rain",
      "icon": "10d"
    }
  ],
  "base": "stations",
  "main": {
    "temp": 298.48,
    "feels_like": 298.74,
    "temp_min": 297.56,
    "temp_max": 300.05,
    "pressure": 1015,
    "humidity": 64,
    "sea_level": 1015,
    "grnd_level": 933
  },
  "visibility": 10000,
  "wind": {
    "speed": 0.62,
    "deg": 349,
    "gust": 1.18
  },
  "rain": {
    "1h": 3.16
  },
  "clouds": {
    "all": 100
  },
  "dt": 1661870592,
  "sys": {
    "type": 2,
    "id": 2075663,
    "country": "IT",
    "sunrise": 1661834187,
    "sunset": 1661882248
  },
  "timezone": 7200,
  "id": 3163858,
  "name": "Zocca",
  "cod": 200
}                        
```

---
#  Forecast API

`api.openweathermap.org/data/2.5/forecast?lat=44.34&lon=10.99&appid={API key}`

```json
{
  "cod": "200",
  "message": 0,
  "cnt": 40,
  "list": [
    {
      "dt": 1661871600,
      "main": {
        "temp": 296.76,
        "feels_like": 296.98,
        "temp_min": 296.76,
        "temp_max": 297.87,
        "pressure": 1015,
        "sea_level": 1015,
        "grnd_level": 933,
        "humidity": 69,
        "temp_kf": -1.11
      },
      "weather": [
        {
          "id": 500,
          "main": "Rain",
          "description": "light rain",
          "icon": "10d"
        }
      ],
      "clouds": {
        "all": 100
      },
      "wind": {
        "speed": 0.62,
        "deg": 349,
        "gust": 1.18
      },
      "visibility": 10000,
      "pop": 0.32,
      "rain": {
        "3h": 0.26
      },
      "sys": {
        "pod": "d"
      },
      "dt_txt": "2022-08-30 15:00:00"
    },
    {
      "dt": 1661882400,
      "main": {
        "temp": 295.45,
        "feels_like": 295.59,
        "temp_min": 292.84,
        "temp_max": 295.45,
        "pressure": 1015,
        "sea_level": 1015,
        "grnd_level": 931,
        "humidity": 71,
        "temp_kf": 2.61
      },
      "weather": [
        {
          "id": 500,
          "main": "Rain",
          "description": "light rain",
          "icon": "10n"
        }
      ],
      "clouds": {
        "all": 96
      },
      "wind": {
        "speed": 1.97,
        "deg": 157,
        "gust": 3.39
      },
      "visibility": 10000,
      "pop": 0.33,
      "rain": {
        "3h": 0.57
      },
      "sys": {
        "pod": "n"
      },
      "dt_txt": "2022-08-30 18:00:00"
    },
    {
      "dt": 1661893200,
      "main": {
        "temp": 292.46,
        "feels_like": 292.54,
        "temp_min": 290.31,
        "temp_max": 292.46,
        "pressure": 1015,
        "sea_level": 1015,
        "grnd_level": 931,
        "humidity": 80,
        "temp_kf": 2.15
      },
      "weather": [
        {
          "id": 500,
          "main": "Rain",
          "description": "light rain",
          "icon": "10n"
        }
      ],
      "clouds": {
        "all": 68
      },
      "wind": {
        "speed": 2.66,
        "deg": 210,
        "gust": 3.58
      },
      "visibility": 10000,
      "pop": 0.7,
      "rain": {
        "3h": 0.49
      },
      "sys": {
        "pod": "n"
      },
      "dt_txt": "2022-08-30 21:00:00"
    },
    ....
    {
      "dt": 1662292800,
      "main": {
        "temp": 294.93,
        "feels_like": 294.83,
        "temp_min": 294.93,
        "temp_max": 294.93,
        "pressure": 1018,
        "sea_level": 1018,
        "grnd_level": 935,
        "humidity": 64,
        "temp_kf": 0
      },
      "weather": [
        {
          "id": 804,
          "main": "Clouds",
          "description": "overcast clouds",
          "icon": "04d"
        }
      ],
      "clouds": {
        "all": 88
      },
      "wind": {
        "speed": 1.14,
        "deg": 17,
        "gust": 1.57
      },
      "visibility": 10000,
      "pop": 0,
      "sys": {
        "pod": "d"
      },
      "dt_txt": "2022-09-04 12:00:00"
    }
  ],
  "city": {
    "id": 3163858,
    "name": "Zocca",
    "coord": {
      "lat": 44.34,
      "lon": 10.99
    },
    "country": "IT",
    "population": 4593,
    "timezone": 7200,
    "sunrise": 1661834187,
    "sunset": 1661882248
  }
}
```





---
# Air Pollution API
---

`http://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=50&lon=50&appid={API key}`

`main.aqi` Air Quality Index. Possible values: 1, 2, 3, 4, 5. Where 1 = Good, 2 = Fair, 3 = Moderate, 4 = Poor, 5 = Very Poor.

```json
{
  "coord":[
    50,
    50
  ],
  "list":[
    {
      "dt":1605182400,
      "main":{
        "aqi":1
      },
      "components":{
        "co":201.94053649902344,
        "no":0.01877197064459324,
        "no2":0.7711350917816162,
        "o3":68.66455078125,
        "so2":0.6407499313354492,
        "pm2_5":0.5,
        "pm10":0.540438711643219,
        "nh3":0.12369127571582794
      }
    }
  ]
}
```

---
# Geocoding API
---

`http://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}`

`http://api.openweathermap.org/geo/1.0/direct?q=London&limit=5&appid={API key}`

```json
[
   {
      "name":"London",
      "local_names":{
         "ms":"London",
         "gu":"લંડન",
         "is":"London",
         "wa":"Londe",
         "mg":"Lôndôna",
         "gl":"Londres",
         "om":"Landan",
         "ku":"London",
         "tw":"London",
         "mk":"Лондон",
         "ee":"London",
         "fj":"Lodoni",
         "gd":"Lunnainn",
         "ky":"Лондон",
         "yo":"Lọndọnu",
         "zu":"ILondon",
         "bg":"Лондон",
         "tk":"London",
         "co":"Londra",
         "sh":"London",
         "de":"London",
         "kl":"London",
         "bi":"London",
         "km":"ឡុងដ៍",
         "lt":"Londonas",
         "fi":"Lontoo",
         "fy":"Londen",
         "ba":"Лондон",
         "sc":"Londra",
         "feature_name":"London",
         "ja":"ロンドン",
         "am":"ለንደን",
         "sk":"Londýn",
         "mr":"लंडन",
         "es":"Londres",
         "sq":"Londra",
         "te":"లండన్",
         "br":"Londrez",
         "uz":"London",
         "da":"London",
         "sw":"London",
         "fa":"لندن",
         "sr":"Лондон",
         "cu":"Лондонъ",
         "ln":"Lóndɛlɛ",
         "na":"London",
         "wo":"Londar",
         "ig":"London",
         "to":"Lonitoni",
         "ta":"இலண்டன்",
         "mt":"Londra",
         "ar":"لندن",
         "su":"London",
         "ab":"Лондон",
         "ps":"لندن",
         "bm":"London",
         "mi":"Rānana",
         "kn":"ಲಂಡನ್",
         "kv":"Лондон",
         "os":"Лондон",
         "bn":"লন্ডন",
         "li":"Londe",
         "vi":"Luân Đôn",
         "zh":"伦敦",
         "eo":"Londono",
         "ha":"Landan",
         "tt":"Лондон",
         "lb":"London",
         "ce":"Лондон",
         "hu":"London",
         "it":"Londra",
         "tl":"Londres",
         "pl":"Londyn",
         "sm":"Lonetona",
         "en":"London",
         "vo":"London",
         "el":"Λονδίνο",
         "sn":"London",
         "fr":"Londres",
         "cs":"Londýn",
         "io":"London",
         "hi":"लंदन",
         "et":"London",
         "pa":"ਲੰਡਨ",
         "av":"Лондон",
         "ko":"런던",
         "bh":"लंदन",
         "yi":"לאנדאן",
         "sa":"लन्डन्",
         "sl":"London",
         "hr":"London",
         "si":"ලන්ඩන්",
         "so":"London",
         "gn":"Lóndyre",
         "ay":"London",
         "se":"London",
         "sd":"لنڊن",
         "af":"Londen",
         "ga":"Londain",
         "or":"ଲଣ୍ଡନ",
         "ia":"London",
         "ie":"London",
         "ug":"لوندۇن",
         "nl":"Londen",
         "gv":"Lunnin",
         "qu":"London",
         "be":"Лондан",
         "an":"Londres",
         "fo":"London",
         "hy":"Լոնդոն",
         "nv":"Tooh Dineʼé Bikin Haalʼá",
         "bo":"ལོན་ཊོན།",
         "ascii":"London",
         "id":"London",
         "lv":"Londona",
         "ca":"Londres",
         "no":"London",
         "nn":"London",
         "ml":"ലണ്ടൻ",
         "my":"လန်ဒန်မြို့",
         "ne":"लन्डन",
         "he":"לונדון",
         "cy":"Llundain",
         "lo":"ລອນດອນ",
         "jv":"London",
         "sv":"London",
         "mn":"Лондон",
         "tg":"Лондон",
         "kw":"Loundres",
         "cv":"Лондон",
         "az":"London",
         "oc":"Londres",
         "th":"ลอนดอน",
         "ru":"Лондон",
         "ny":"London",
         "bs":"London",
         "st":"London",
         "ro":"Londra",
         "rm":"Londra",
         "ff":"London",
         "kk":"Лондон",
         "uk":"Лондон",
         "pt":"Londres",
         "tr":"Londra",
         "eu":"Londres",
         "ht":"Lonn",
         "ka":"ლონდონი",
         "ur":"علاقہ لندن"
      },
      "lat":51.5073219,
      "lon":-0.1276474,
      "country":"GB",
      "state":"England"
   },
   {
      "name":"City of London",
      "local_names":{
         "es":"City de Londres",
         "ru":"Сити",
         "ur":"لندن شہر",
         "zh":"倫敦市",
         "en":"City of London",
         "pt":"Cidade de Londres",
         "fr":"Cité de Londres",
         "uk":"Лондонське Сіті",
         "he":"הסיטי של לונדון",
         "hi":"सिटी ऑफ़ लंदन",
         "ko":"시티 오브 런던",
         "lt":"Londono Sitis"
      },
      "lat":51.5156177,
      "lon":-0.0919983,
      "country":"GB",
      "state":"England"
   },
   {
      "name":"London",
      "local_names":{
         "el":"Λόντον",
         "fr":"London",
         "oj":"Baketigweyaang",
         "en":"London",
         "bn":"লন্ডন",
         "be":"Лондан",
         "ko":"런던",
         "he":"לונדון",
         "ru":"Лондон",
         "lt":"Londonas",
         "hy":"Լոնտոն",
         "ga":"Londain",
         "ja":"ロンドン",
         "yi":"לאנדאן",
         "cr":"ᓬᐊᐣᑕᐣ",
         "iu":"ᓚᓐᑕᓐ",
         "ar":"لندن",
         "lv":"Landona",
         "fa":"لندن",
         "ug":"لوندۇن",
         "th":"ลอนดอน",
         "ka":"ლონდონი"
      },
      "lat":42.9832406,
      "lon":-81.243372,
      "country":"CA",
      "state":"Ontario"
   },
   {
      "name":"Chelsea",
      "local_names":{
         "id":"Chelsea, London",
         "uk":"Челсі",
         "hi":"चेल्सी, लंदन",
         "ga":"Chelsea",
         "es":"Chelsea",
         "de":"Chelsea",
         "af":"Chelsea, Londen",
         "vi":"Chelsea, Luân Đôn",
         "pl":"Chelsea",
         "pt":"Chelsea",
         "da":"Chelsea",
         "ko":"첼시",
         "sv":"Chelsea, London",
         "nl":"Chelsea",
         "az":"Çelsi",
         "it":"Chelsea",
         "hu":"Chelsea",
         "no":"Chelsea",
         "fr":"Chelsea",
         "he":"צ'לסי",
         "eu":"Chelsea",
         "ru":"Челси",
         "ar":"تشيلسي",
         "en":"Chelsea",
         "el":"Τσέλσι",
         "tr":"Chelsea, Londra",
         "zh":"車路士",
         "sh":"Chelsea, London",
         "ja":"チェルシー",
         "ur":"چیلسی، لندن",
         "sk":"Chelsea",
         "fa":"چلسی",
         "et":"Chelsea"
      },
      "lat":51.4875167,
      "lon":-0.1687007,
      "country":"GB",
      "state":"England"
   },
   {
      "name":"London",
      "lat":37.1289771,
      "lon":-84.0832646,
      "country":"US",
      "state":"Kentucky"
   }
]
```
