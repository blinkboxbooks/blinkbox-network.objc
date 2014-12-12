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


##Updating Cocoapods version of BBBAPI (v1)

Prerequisites:

a. you have to have [Blinkbox Books pod repo](https://git.mobcastdev.com/iOS/Specs) added as a spec repo in you cocoapods installation [private cocoapods](http://guides.cocoapods.org/making/private-cocoapods.html)

---

1. Pull latest changes from `master` branch
2. Remember to add all dependecies of `BBBAPI` target to `BBBAPI.podspec` (all pods in podspec for BBBAPI)
4. Modify `BBBAPI.podspec` to set new version of the pod
5. Commit, add new git-tag with version the same as in the `BBBAPI.podspec`
6. Push to upstream-master
7. Execute this command from the `BBBAPI` root directory:
```
pod repo push BBB BBBAPI.podspec --allow-warnings
```

6. If it doesn't push (branch name is wrong, we need to fix this, see error below), go to `~/.cocoapods/BBB` and do `git push` yourself.

```
error: src refspec master does not match any.
error: failed to push some refs to 'git@git.mobcastdev.com:iOS/Specs.git'
```