![enter image description here](https://raw.githubusercontent.com/nsaigal/CalorieCounter/master/CalorieApp/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png?token=ADLVG77MJP7Z42H5N4SNE526S535K)
# Calorie Counter
iOS app that tracks energy consumption &amp; expenditure over time

## Features

1. **Add food consumed and see total calories**
- Show the list of foods already consumed today
- Add new entries with label, calories, quantity, and meal (breakfast, lunch, etc)
- Optionally add item picture using the Photo Library or Camera (or use a default icon)
- Add new entry from saved menu items
- See the total calories for the day
- Remove entries from list
- Add/remove entries to view in user's Apple Health app (HealthKit)

2. **Create a menu of the foods you frequently eat**
-   Every item has a picture, label & calories
-   Add new pictures using the Photo Library or Camera (or use a default icon)
-   Remove items from the list
-   Picture, label, and calories should be editable with previously created items

3. **View intake trends over time**
- Review bar charts (CareKitUI) that compare consumption data to activity data
- Charts will show trends over 7 days, 4 weeks, and 6 months
- Import activity data from Apple Health (HealthKit)
- Select "Use Test Data" button to randomize data in the charts

## UI Design
The UI for this app was mocked up in Figma to create a wireframe to build from. Icons were taken from free graphic design resources. The Trends screen was built using Apple's CareKitUI library invoking OCKCartesianChartView classes. Since this is a demo app and relatively small, the screens were built using the storyboard and custom XIB files and then tested on multiple device screens.

![enter image description here](https://raw.githubusercontent.com/nsaigal/CalorieCounter/master/Today.PNG?token=ADLVG72AZDZSNXTFRCGHIEC6S6DJA)

![enter image description here](https://raw.githubusercontent.com/nsaigal/CalorieCounter/master/Add.PNG?token=ADLVG76I76ABUE53FHVH6XC6S6DOY)

![enter image description here](https://raw.githubusercontent.com/nsaigal/CalorieCounter/master/Menu.PNG?token=ADLVG73ALF26H7L5DTNQV4S6S6DQC)

![enter image description here](https://raw.githubusercontent.com/nsaigal/CalorieCounter/master/Trends.PNG?token=ADLVG74VGKC4JIVM5V3IP3S6S6DR6)
### Dark Mode Support

![enter image description here](https://raw.githubusercontent.com/nsaigal/CalorieCounter/master/Trends-Dark.PNG?token=ADLVG7YM6YPABTLSTIT74226S6DS4)
![enter image description here](https://raw.githubusercontent.com/nsaigal/CalorieCounter/master/Menu-Dark.PNG?token=ADLVG7YNXZK46AMD453642C6S6DTS)

## Libraries

 - Core Data
 - HealthKit
 - CareKitUI

## Demo
