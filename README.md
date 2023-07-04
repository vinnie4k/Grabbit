# Grabbit

![swift-badge](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![javascript-badge](https://img.shields.io/badge/JavaScript-323330?style=for-the-badge&logo=javascript&logoColor=F7DF1E)
![firebase-badge](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)
![express-badge](https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white)
![figma-badge](https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white)

## Overview
<img src="https://github.com/vinnie4k/Grabbit/assets/75594943/ad8a6dc3-081a-4a90-ae2e-cba01525f939" width="200px" height="auto">
<img src="https://github.com/vinnie4k/Grabbit/assets/75594943/3fe344e8-d508-43b7-b84a-5c8a6b7c6ab3" width="200px" height="auto">
<img src="https://github.com/vinnie4k/Grabbit/assets/75594943/7ce5d194-5546-492e-b943-e6aeb17549b5" width="200px" height="auto">
<img src="https://github.com/vinnie4k/Grabbit/assets/75594943/d702ee56-1428-4c43-8a94-caaa36101268" width="200px" height="auto">

Pre-enroll didn't go so well? Are all of your classes full? Grabbit is here to help!

Search for your course through the app to begin tracking. Grabbit will notify you when a spot opens up, and you can quickly copy the section code and go to Student Center through the app. Sit back, relax, and enable push notifications!

You can download the app [here](https://apps.apple.com/us/app/grabbit/id6450518666)!

## Features
- Search thousands of courses offered at Cornell
- Select the courses and sections you want to track
- Enable push notifications to be notified when a spot opens up
- Copy the code and navigate to Student Center directly through the app
- Save your tracked courses by signing in with a Google account


## Design + Development
- Implemented a design system to be used throughout the design journey, including colors, typography, etc.
- Used Figma components and auto-layout to create wireframe iterations following a grid system
- Backend data is stored in a Firebase Firestore database, accessed using FirebaseSDKs for NodeJS
- Serverless backend using ExpressJS to create a REST API for Firebase Cloud Functions
- Course information is fetched from Cornell's public Class Roster API
- Frontend UI is created with SwiftUI
- Network requests are sent using Alamofire and called with Swift Concurrency
- FirebaseMessaging and GoogleAnalytics are used for user retention and UX improvements

## Other Info
Have any questions and would like to provide feedback on the app? Fill out [this form](https://forms.gle/ZZA9Afikkx8N5aZb7). If you would like to learn more about Grabbit, visit [this website](https://vinbui.me/work/grabbit).
