# **🎥 MyAnimeList Automator**

🚀 A set of scripts to **sync your anime list with MyAnimeList (MAL) from HiAnime effortlessly**! Whether you want to update your MAL watch status from a JSON file **or generate an XML file for import**, these scripts have got you covered!



## **📌 Features**


✅ **Update MyAnimeList Automatically** – Syncs your anime list using the MAL API

✅ **Generate a MyAnimeList XML File** – Perfect for backups and imports

✅ **Supports Multiple Platforms** – Works on **Windows, macOS, and Linux**

✅ **Fun & Easy to Use** – Just run a script, sit back, and relax!


## **🔧 Installation**


Before running the scripts, you’ll need to install a few dependencies. Follow the instructions below based on your OS.



### **🐧 Linux & 🍎 macOS**



1️⃣ Install jq (for JSON processing):


```sh
sudo apt install jq -y  _# Ubuntu/Debian_

brew install jq _# macOS (Homebrew)_

sudo pacman -S jq _# Arch Linux_
```


2️⃣ Install curl (if not already installed):


```sh
_# Ubuntu/Debian_
sudo apt install curl -y

_# macOS (Homebrew)_
brew install curl
```


### **🪟 Windows**


1️⃣ Install [Git for Windows](https://gitforwindows.org/) (includes bash and curl)


2️⃣ Install jq:

•  Download it from [stedolan.github.io/jq/download](https://stedolan.github.io/jq/download)

•  Place the jq.exe file in C:\Windows\System32\


## **🚀 Usage**


There are **two scripts** in this repo:


**1️⃣ update_mal_status.sh – Syncs Your MAL List**

This script updates your MyAnimeList watch status based on a JSON file.


### 📌 **Steps to use:**

1️⃣ Replace ACCESS_TOKEN="your_access_token" in the script with your actual MAL OAuth2 token

2️⃣ Place your anime list inside export.json

3️⃣ Run the script:


```sh
bash update_mal_status.sh
```


**2️⃣ export_to_xml.sh – Generates a MAL XML File**



This script converts your JSON anime list into an XML format for MyAnimeList import.



### 📌 **Steps to use:**

1️⃣ Place your anime list inside export.json

2️⃣ Run the script:


```sh
bash export_to_xml.sh
```


3️⃣ Your XML file will be generated as mal_export.xml 🎉



### **📜 JSON Format**



Your export.json should look like this:


```json
{
    "Watching": [
        { "name": "Attack on Titan", "link": "https://myanimelist.net/anime/16498" }
    ],
    "Completed": [
        { "name": "Death Note", "link": "https://myanimelist.net/anime/1535" }
    ]
}
```


## **❤️ Contributing**



Found a bug? Have an idea? Open an **issue** or send a **pull request**! 🚀



## **📜 License**


This project is licensed under the **MIT License** – feel free to modify and share it! 🎉

Now go forth and automate your anime list! 🎬🍿🚀