# NnExecutableKit  

**NnExecutableKit** is a Swift package for managing Swift project executables. It builds executables from Swift Packages or Xcode projects and moves them to a user-defined directory for easy access.  

## Features  
- Supports both **Swift Packages** and **Xcode projects**  
- Builds executables in **Debug** or **Release** mode  
- Saves and retrieves the destination path for executables  
- Provides a command-line interface with `ArgumentParser`  

## How It Works  
1. Detects project type (**Swift Package** or **Xcode project**)  
2. Builds the executable with `swift build` or `xcodebuild`  
3. Moves the executable to the saved destination 

## Installation  

<!-- Command to clone and build the package -->

## Usage  

### **Set the destination folder for executables**  

```sh
nnexec set-path /your/destination/folder
```

### **Build and move an executable**  

```sh
nnexec -r  # Release build  
nnexec -d  # Debug build
```

### **Print the saved destination path**  
```sh
nnexec print-path
```

### **Delete the saved destination path**  
```sh
nnexec delete-path
``` 

## License  
[MIT](LICENSE)  
