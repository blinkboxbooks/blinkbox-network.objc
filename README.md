#BBBAPI


##Project Structure

The BBBAPI Project consists of the BBBAPI Library, BBBTool and BBBApp.

### BBBAPI
The BBBAPI Project provides access to the blinkbox books REST API.


#### BBBTool
BBBTool is a command line app for OSX to provide quick access to API methods and other related tasks. 

Currently, BBBTool implements `login` and `help` commands. In the future, we can extend this to access all API methods, and more importantly, it can be used for end to end and integration testing by QA (calling out to a CLI app in ruby is trivial). Hopefully this will be very useful.

#### BBBAPI
The BBBApp project is a placeholder empty iOS application which is linked against `libBBBAPI.a`. Its current purpose is to ensure that the iOS library builds correctly and has the correct public headers provided.


## Development

First step is generate `xcworkspace` by running

```
pod install
```

in the `BBBAPI` or `BBBTool` directory