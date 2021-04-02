# Hello Contibutors 🤗

- If you want to have a feature in the project open an [issue](https://github.com/SirusCodes/Heartry/issues) in the repository.
- Found an issue and want to fix it? Thanks a lot, go ahead.
- Fork the project and `git clone https://github.com/<YourUserName>/Heartry.git`
- Create another branch `git checkout -b <branch-name>`
- Add an upstream `git remote add upstream https://github.com/SirusCodes/Heartry.git`
- Run `flutter pub get & flutter pub run build_runner build`
- Make required changes
- Make a [pull request](https://opensource.com/article/19/7/create-pull-request-github)

## Things to remember

- Try to avoid adding new dependencies to save an hour.
- Format your code by running `flutter format`
- Write short and concise commit message and titles.

## Project structure we follow

```
|--assets                           # Assets for app(logos, fonts)
|--lib
    |--database                     # Everything related local storage
    |--models
    |--providers                    # Every provider should be in different file
    |--screens                      # Contains all the UI elements of app
        |--<foo>_screen             # Each screen should have a folder and follow foo_screen convention
            |--widgets              # Smaller widgets which help in building the screen
            |--foo_screen.dart      # App screen
    |--utils                        # Helper class/function which don't paint to UI but are used in logic
    |--widgets                      # Widgets which are shared between more that one screen
    |--init_get_it.dart             # Initialize get_it
    |--main.dart                    # Entry point of any dart project
```