![App Icon](/CalorieApp/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png?raw=true)
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

![Today](/Today.PNG?raw=true)

![Add](/Add.PNG?raw=true)

![Menu](/Menu.PNG?raw=true)

![Trends](/Trends.PNG?raw=true)
### Dark Mode Support

![Trends-Dark](/Trends-Dark.PNG?raw=true)
![Menu-Dark](/Menu-Dark.PNG?raw=true)

## Libraries

 - Core Data
 - HealthKit
 - CareKitUI

## Demo
