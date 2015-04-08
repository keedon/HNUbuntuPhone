
var commentStack = [];
var currentIndent = 0;
var currentArticle;

/*
 * Need this because the ListModel seems to screw up the 'kids' array,
 * so we keep another
 */
var commentsArray = [];

function loadStories() {
    articleView.currentIndex = -1;
    commentsArray.length = 0;
    getJson("https://hacker-news.firebaseio.com/v0/topstories.json", updateList);
};

function addToList(article) {
    if (article.type === "story") {
        stories.append(article);
        commentsArray.push(article);
    }
};

function updateList(topItems) {
    stories.clear();
    for (var i = 0; i < topItems.length; i++) {
        getJson("https://hacker-news.firebaseio.com/v0/item/" +
                topItems[i] + ".json", addToList);
    }
};

function getJson(url, callback) {
    var http = new XMLHttpRequest()
    http.open("GET", url, true);
    http.onreadystatechange = function() {
        if (http.readyState === 4) {
            if (http.status === 200) {
                callback(JSON.parse(http.responseText));
            } else {
                console.log("error: " + http.status);
            }
        }
    }
    http.send();
};

function displayArticle(index) {
    currentArticle = commentsArray[index];
    articleWebView.url = currentArticle.url;
    articlePage.title = currentArticle.title;
    pageStack.push(articlePage);
};

function displayComments() {
    commentStack.length = 0;
    currentIndent = 0;
    commentModel.clear();
    if (currentArticle.kids === undefined) {
        commentModel.append({"comment": "No comments", "cmtLevel": 0});
        return;
    }

    commentStack.push(currentArticle.kids.slice(0));
    loadComments();
    pageStack.push(articleComments);
}

function loadComments() {
    if (commentStack.length === 0) {
        console.log("Load complete");
        return;
    }
    var commentsAtThisLevel = commentStack.pop();
    if (commentsAtThisLevel.length === 0) {
        currentIndent--;
        loadComments();
        return;
    }
    var nextComment = commentsAtThisLevel.pop();
    commentStack.push(commentsAtThisLevel);
    getJson("https://hacker-news.firebaseio.com/v0/item/"
            + nextComment + ".json", kidLoaded);
};

function kidLoaded(comment) {
    comment.cmtLevel = currentIndent;
    console.log(JSON.stringify(comment));
    if (comment.deleted) {
        commentModel.append({"comment": "[deleted]<br/>&nbsp;<br/>", "cmtLevel": currentIndent * 3});
    } else {
        commentModel.append({"comment": "<small><b>" + comment.by + "</b></small> " +
                                        comment.text + "<br/>&nbsp;<br/>", "cmtLevel": currentIndent * 3});
    }
    console.log(JSON.stringify(commentModel));
    if (comment.kids !== undefined &&
            comment.kids.length > 0) {
        currentIndent++;
        console.log("currentIndent=" + currentIndent);
        commentStack.push(comment.kids);
    }
    loadComments();
};

function followLink(link) {
    console.log(link);
}
