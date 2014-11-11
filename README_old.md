#BBBAPI


##Project Structure

The BBBAPI Project consists of the BBBAPI Library, BBBTool and BBBApp.

### BBBAPI
The BBBAPI Project provides access to the blinkbox books REST API.

There are 5 build targets for BBBAPI:

* #### libBBBAPI.a
This builds the BBBAPI code into an iOS static library + public headers. This can be used with an iOS app by adding the static library and public headers to the iOS project.

* #### libBBBAPI.a Tests
This is the tests target for the iOS static library.  Running tests on this target will perform all unit tests against the compiled iOS library on an iDevice or simulator.

* #### BBBAPI.framework
This target builds the API code into a mac OSX dynamic framework. The built framework contains the code library and publi headers.

* #### BBBAPI
This target builds the API code into a mac OSX static library. This library can be linked against by adding the library and public headers to a mac OSX project. This is currently used 
for BBBTool to link against.

* #### BBBAPI.framework Tests
This is the tests target for the OSX framework and static library. Running tests on this target will perform all unit tests against the compiled OSX library.

### BBBTool
BBBTool is a command line app for OSX to provide quick access to API methods and other related tasks. 

Currently, BBBTool implements `login` and `help` commands. In the future, we can extend this to access all API methods, and more importantly, it can be used for end to end and integration testing by QA (calling out to a CLI app in ruby is trivial). Hopefully this will be very useful.

### BBBApp
The BBBApp project is a placeholder empty iOS application which is linked against `libBBBAPI.a`. Its current purpose is to ensure that the iOS library builds correctly and has the correct public headers provided.


## Development
### Adding new classes
 
When adding new classes to the library project, it is **IMPORTANT** to add your implementation files to the 3 library targets: `BBBAPI.framework`, `libBBBAPI.a` and `BBBAPI`. This ensures that code is built for all compatible targets.

### Adding new Unit Tests
When adding new test classes to the library project, it is **IMPORTANT** to add the implementation files to the 2 test targets:'BBBAPI.framework tests' and 'libBBBAPI.a tests'

### Public Headers
The BBBAPI.framework and libBBBAPI.a targets both contian a build phase which copies **public** headers to the build location.

When contributing to BBBAPI it is **important** that headers which should be visible to the consumer of the library are added to these build phases. 

**NOTE:** **ONLY** the headers which should be public should be added to the copy headers phase. Please think carefully about which headers should be exposed and which should remain private to the library.