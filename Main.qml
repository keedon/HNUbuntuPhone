import QtQuick 2.0
import Ubuntu.Components 1.1
import QtQuick.Layouts 1.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Web 0.2 as Web
import "app.js" as App

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "hackernews.keithpoole"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(100)
    height: units.gu(75)

    PageStack {
        id: pageStack
        Component.onCompleted:  {
            App.loadStories();
            push(articleList);
        }

        Page {
            id: articleList
            visible: false
            title: i18n.tr("Hacker News")
            tools: ToolbarItems {
                ToolbarButton {
                    action: Action {
                        text: "button"
                        iconName: "reload"
                        onTriggered: App.loadStories();
                    }
                }
            }

            ListModel {
                id: stories
            }

            ColumnLayout {
                spacing: units.gu(1)
                anchors {
                    margins: units.gu(2)
                    fill: parent
                }

                UbuntuListView {
                    id: articleView
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: stories
                    highlightFollowsCurrentItem: true
                    delegate: ListItem.Standard {
                        text: title
                        progression: true
                        onClicked: {
                            App.displayArticle(index)
                        }
                    }
                    width: parent.width
                }
                focus: true
            }
        }
        Page {
            tools: ToolbarItems {
                ToolbarButton {
                    action: Action {
                        text: "button"
                        iconName: "user-switch"
                        onTriggered: App.displayComments();
                    }
                }
            }
            id: articlePage
            title: "Article"
            visible: false
            Web.WebView {
                id: articleWebView
                anchors.fill: parent
            }
        }
        Page {
            id: articleComments
            title: i18n.tr("Comments")
            visible: false

            tools: ToolbarItems {
                ToolbarButton {
                    action: Action {
                        text: "button"
                        iconName: "user-switch"
                        onTriggered: pageStack.pop();
                    }
                }
            }

            ListModel {
                id: commentModel
            }

            ColumnLayout {
                spacing: units.gu(1)
                anchors {
                    margins: units.gu(2)
                    fill: parent
                }

                UbuntuListView {
                    id: commentView
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: commentModel
                    highlightFollowsCurrentItem: true
                    delegate: TextArea {
                        readOnly: true
                        textFormat: TextEdit.RichText
                        text: comment
                        autoSize: true
                        maximumLineCount: 0
                        width: parent.width - units.gu(cmtLevel)
                        anchors.right: parent.right
                    }
                    width: parent.width
                }
                focus: true
            }
        }
    }
}

