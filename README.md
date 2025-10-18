# Neverest
## "One step at a time"

## Getting Started
    //TODO: Give a short introduction of the project

# Getting Started
    //TODO docs about:
    1. Installation process
    2. Software dependencies
    3. Latest releases
    4. API references
    5. Adding dependencie: pubspec.yaml + app current version

# Build || Test || Deploy || Merge
    //TODO: Describe more and show how to build your code and run the tests
    - BUILD:
            - 
    - TEST:
            -
    - DEPLOY:
            -

## USEFUL TERMINAL COMMANDS
    - run the following command in terminal for updating the translate:
         flutter gen-10ln
            OR:  flutter pub get (because the project has generate:true in pubspec.yaml)

    - run the following command in terminal in case of:
            1. Each model added/removed that containts @JsonSerializable(), @freezed, @injectable tags
            2. .arb files for translate were modified
            3. New REST client added
        flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

    - run the following command for changing launcher icons on android/ios and  change the image in pubspec.yaml:
       flutter pub get
       flutter pub run flutter_launcher_icons
    
    - run the following commans for a clean restart without hot reload
        flutter clean
        flutter pub get
        flutter run


## NAMING CONVENTION
    - USE ONLY ENGLISH FOR CLARITY AND CONSISTENCY
    - Constants are declared with CAPS and SNAKE_CASE (ex: CHELZO_BOZ)
    - File naming (ex: iancu_robila)
    - Comments/docs are starting with Capital Letter, with only 1 space after the //, above the method/widget using: // for comments and ///*** for docs (especially for custom classes) (ex: // This method shows the hau, bau, miau)
    - The routes ar named using camelCase (/iancuRasta)
    - The widgets from /lib/core/widgets are declared like this: App[WidgetName]: Ex: AppBar (so you can easily find them using double SHIFT)
    - If TODOs need to remain in the app after merging with master branch, please let them inside the methods like so: //TODO: brief description

## CLEAN ARCHITECTURE RULES: 
    - DRY principle
    - Single responsability principle for methods and classes
    - Between methods leave only 1 empty line
    - Try not to be verbose in you code. Keep as less code as you can for your implemntations
    - Try as much as you can to remove the BIG warnings in you code
    - NEVER PUSH IN MASTER DIRECTLY WITHOUT PULL REQUEST & AND PROPER CODE REVIEW UNTIL WE CAN RESTRICT THE MASTER BRANCH ON GITHUB
    - Before merging with master branch, delete any unused blocks of code, unused imports, commented code

    



## TO STUDY: riverpod, MVVM and MVI architecture: state management with state(ref.read, ref.watch/ref.listen)





