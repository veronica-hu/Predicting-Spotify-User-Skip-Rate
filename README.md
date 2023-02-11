# Predicting User Skip Rate on Spotify

## Overview
One of the most pressing issues for online service providers is to understand and forecast user behavior. This has led to a lot of research on click modeling. A central challenge for Spotify is to recommend the right music to each user. In particular, the question of if and when a user skips a track is an important implicit feedback signal for music recommendation. <br>
Using Spotify's 2018 data ([The Music Streaming Sessions Dataset](https://arxiv.org/abs/1901.09851)), this project focuses on the task of session-based skip prediction, i.e. predicting whether users will skip tracks, given their behavior and interactions in their listening sessions. <br>
The two main sources of revenue for Spotify is through subscriptions and advertisements. The end goal of skip prediction is to keep users listening to music on the application, by comprehending their tastes — including what music they do not listen to. A customer's listening experience relates to the amount of time they spend on the application, which consequently affects advertising revenues and number of subscribers. 

## Data Understanding & Preparation
### Data Selection
The original dataset consists of 160 million Spotify listening sessions and user interactions (over 50 GB of zipped data, 350 GB after unzipped). Due to limited computer memory and excessive amounts of data, this may make the modeling process very time-consuming. Considering this, we choose to random sampling a subset of the original dataset. 

### Dataset Overview
The randomly sampled dataset consists of 2,073,469 tracks (rows) and 21 variables. Four features are related to the target variable: "skip_1", "skip_2", "skip_3" and "not_skipped" which measure the degree of skipping a track differently. For the prediction in this project, we will mainly focus on the prediction of "skip_1".

### Data Cleaning
This dataset has no empty values. For categorical variables, we choose to use one hot encoding to transform them into dummy variables (using model matrix). For example, original column "context_type" is converted to "context_catalo", "context_charts", "context_editorial", "context_personalized", "context_radio" and "context_collection". Continuous variables remain the same.

### Exploratory Data Analysis 
We first looked at the top five tracks listened to across all sessions. We found that the proportion of sessions of a given length decreases steadily with increasing length. Moreover, session length of 20 has the maximum frequency since sessions that are 20 or more tracks long are capped at this length.<br>
Next, we noticed a trend in listening behavior across multiple skip levels. The proportion of skips for "skip_3" (where most of the track was played) was significantly higher than that of "skip_1" (where a track was played very briefly).<br>
However, regardless of the time-stamp a song was skipped at (i.e, whether at the beginning of the song, middle of the song, or end of the song), the patterns of skipping across length of sessions followed a pattern. At the individual skip levels, the proportion of skipped tracks increased/decreased at a similar rate.<br>
We also noticed that Spotify offers many ”context“ based listening experiences - this includes their curated catalogs, charts, collaborative playlists, or radio options depending on your saved songs. We compared switch rates for different context types and found that users tend to switch out of catalog and are least likely to switch from their own collections.

### K-means Clustering
Since all the variables in our dataset are categorical, we cannot perform PCA on our dataset. Hence we choose to perform k-means with a k equal to 6. Below are the six clusters based on different patterns and user behaviors when they are playing a track. <br>

*Cluster 1: "Let the music play"* <br>
Reason for starting and ending the current track is because the track is done. This indicates that tracks are played continuously without interruption, hence less likely to be skipped. 
<br><br>
*Cluster 2:* <br>
Tracks are played after the previous track is done and a long pause, and skipped after the majority parts have been played. 
<br><br>
*Cluster 3: Traceback to look for previous songs* <br>
Tracks are played and skipped very quickly by clicking the “back” button, probably because the user is tracing back to look for previous songs in the list. <br><br>
*Cluster 4: Move forward to look for better songs* <br>
Similar to cluster 3, tracks are played and skipped very quickly by clicking the “forward” button, probably because the user is looking for a more satisfying song. 
<br><br>
*Cluster 5: Searching for specific song to play* <br>
Tracks tend to be at early positions during a listening session and played by clicking or selecting. This indicates that users are searching for a specific track instead of just playing a certain playlist in sequence. 
<br><br>
*Cluster 6: Spotify Charts Listeners* <br>
All tracks in this cluster are from Spotify Charts, most of which played in the charts’ sequence and skipped quickly by clicking the forward button. 
<br><br>

## Modeling
Our target variable (skip_1) contains two labels: skip (1) or not skip (0). Therefore we will use supervised classification models, i.e. logistic regression, classification tree and random forest to predict the binary outcome. 

## Evaluation
### Evaluation Metric
We used out-of-sample accuracy as the evaluation metric to compare the model performance. Accuracy is defined as the number of correct predictions (i.e. True Positives and True Negatives) as a percentage of the total number of values to predict. To improve the stability of out-of-sample performance, we perform a 5-fold cross validation and calculate the mean of OOS accuracy on each model. 

### Model Results
Random Forest is our best model because it has the highest OOS accuracy at 0.883. We can re-train it on the whole training dataset for further prediction use.

## Deployment
The results from this analysis could allow further research in important business problems like session based sequential recommendations and creating user journeys. With limited user data, such insights are of key importance when onboarding new users. <br>
The main objective of our model is to improve the song recommendation system. For instance, if Spotify predicts that a user will skip the next song, they will never recommend or auto-play that song for the user. This in turn improves instantaneous user satisfaction. Since one of the main sources of revenue (90% of total revenue) for Spotify is user subscriptions, a better user experience leads to more subscriptions. Primarily, we signify that skip behavior in a session is correlated with prior skip behavior within the same session. <br>
Our model predicts that if the skipping rate is higher than 50%, the user is not happy with the current selection of tracks. This means that Spotify should reassess their recommendation algorithms. This will help optimize future user sessions in the long-run. 
