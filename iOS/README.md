# MousePort iOS

## Getting Started

Mac is required

Create dylibs directory

```
cd ~/Downloads && mkdir dylibs
```

Download the dynamic library

```
cd ~/Downloads/dylibs && curl -LO "https://github.com/iPAWiND/MousePort/releases/download/ios-dynamic-library/latest.zip" && unzip latest.zip && rm latest.zip
```

### Patching

Using [iPatch](https://github.com/iPAWiND/iPatch)

```
cd ~/Desktop/iPatch && ./ipatch.sh 'path_to_ipa_file' ~/Downloads/dylibs 'path_to_mobile_provision(optional)'
