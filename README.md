# Griddler Mobile Game iOS Client Sample

This project is an implementation of iOS client that works with [Griddler mobile game backend sample](https://github.com/GoogleCloudPlatform/solutions-griddler-sample-backend-java).

## Copyright
Copyright 2013 Google Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Disclaimer
This sample application is not an official Google product. The purpose of this sample is to demonstrate how to power a mobile game with a game backend running on Google App Engine. The sample is not intended to represent best practices in iOS application development.

## Supported Platform and Versions
This sample source code and project is designed to work with Xcode. It was tested with Xcode 5.0.

## Developer Guide
This section provides a step-by-step guide so you can get the sample up and running in Xcode.

### Prerequisite
1. Download and install [Xcode 4.6](https://developer.apple.com/xcode/) on your Mac computer if you don't have it installed.

2. Setup [Griddler mobile game backend](https://github.com/GoogleCloudPlatform/solutions-griddler-sample-backend-java).

#### Open Griddler.xcworkspace in Xcode
1. Open a new Finder window and navigate to the directory you extract the sample client code.  Double click on the Griddler.xcworkspace file. It will open the project in Xcode automatically.

#### Rename the bundle ID
1. The iOS client application bundle ID has to match the one you used for creating the SSL certificate and the Provisioning Profile.  Out-of-the-box bundle ID is `com.google.cloud.solutions.griddler.ios`.  Please rename the bundle ID accordingly via project TARGETS in Xcode.

#### Update the Client ID, Client Secret and Service URL
1. Fill in the kAuthClientID and kAuthClientSecret values in Constants.m.  The ClientID has to match with the Client ID you used in the backend as described in step 5 of the Prerequisite.  The kAuthClientSecret is the matching client secret for the Client ID from [API Console](https://code.google.com/apis/console).
2. Replace *yourappid* in the kGriddlerServiceUrl variable in Constants.m with the App Engine Application id where the Griddler mobile game backend is deployed.

#### Update the Code Signing Certificate
1. Click on the project in the File Browser panel
2. Click on the project in the Settings browser
3. Click on the Build Settings tab
4. Browse down to Code Signing Identity
5. Select a valid code signing certificate (APNS enabled provisioning profile)

### Build and Execute Griddler iOS Client
1. On the top left corner of the toolbar, select `[Your bundle ID] > iOS Device`.  Then click the `Run` button to execute the application.
2. The application should open up in your iPhone.
