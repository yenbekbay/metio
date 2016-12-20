#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(4);
captureLocalizedScreenshot("0-WeatherView");
window.scrollViews()[0].buttons()["Stories Button"].tap();
target.delay(1);
captureLocalizedScreenshot("1-StoriesView");
window.scrollViews()[0].buttons()["Submit Story Button"].tap();
target.delay(1);
window.elements()["Story Form View"].textViews()["Story Text View"].setValue("Пишите свои истории");
window.navigationBars()["Story Form Navigation Bar"].tap();
target.delay(1);
captureLocalizedScreenshot("2-StoryFormView");
