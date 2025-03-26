---
#title: DeniedPluto's Big Page of Little Data
#githubRepo: https://github.com/Deniedpluto
---

<img src="https://avatars.githubusercontent.com/deniedpluto" alt="Peter" class="rounded-full w-48 h-48 mb-4">

## Peter Matson

<div style="display: flex; flex-direction: row; gap: 10px;">
    <a href="https://www.linkedin.com/in/peterdoesdata/"><img src="https://img.shields.io/badge/LinkedIn-blue" alt=LinkedIn></a>
    <a href="https://github.com/deniedpluto"><img src="https://img.shields.io/badge/GitHub-black" alt="GitHub"></a>
</div>

## My Data World

As a certified nerd, I love to collect data and mine it for insights. Over the years, I have collected data across many personal projects and now I am taking my first steps to bring the display of it all into a single place. Below you will find a list of my current data projects. There are a few that haven't been pulled together yet, but hopefully we will have them all live before the end of Q1 2025.

- [Espresso Shot Analysis](Espresso/EspressoData)
- [MTG Commander Analysis](Commander/CommanderHome)
- [Custom MTG D&D Set](https://deniedpluto.github.io)
- *Board Game Recommendation Engine*
- [Board Game Geek Analysis](BGGDashboard/BGGDashboard)
- [Board Game Plays](BoardGamePlays/BoardGamePlaysHome)


## Overview of the data

### Espresso Shot Analysis
[Repo](https://github.com/Deniedpluto/motherduck_data_update)

The espresso shot data is collected in a Google Form which loads the data into a Google Sheet. The data from the Google Sheet is loaded into Motherduck via github actions and refreshed nightly. 

### MTG Commander Analysis
[Repo](https://github.com/Deniedpluto/MTG-Battle-Logger)

The MTG Commander Analysis data comes from MotherDuck. An R Shiny app is used to record games and updates the Elos then a secondary R Script calculates the win rate against and the decks *strength* then runs a python script to write the data to Motherduck. Deck Tags is a Google Sheet that is manually filled out and loaded into Motherduck via GitHub Actions.

### Custom MTG D&D Set
[Repo](https://github.com/Deniedpluto/deniedpluto.github.io)

The Custom MTG D&D Set is a set of cards that I have created based on the D&D Campaigns I have run since starting to DM back in 2017. The cards were created using [Magic Set Editor](https://magicseteditor.boards.net/) then exported to images and text files. A python script preps and loads the data to GitHub Pages.

### Board Game Recommendation Engine
[Repo](https://github.com/Deniedpluto/BGG_Recommender)

I built this recommendation engine a few years ago as an extension of work I had been doing using cosine similarity. I built an R Shiny app that allowed an end user to input a users boardgamegeek (BGG) username and pull their collection and rating information down. I then used this app to create a small database of some of the top contributors to BGG and their collections. I then used this database to create a recommendation engine that would take a user's collection and find similar users and recommend games that those users had rated highly. The app is currently not live, but the code is available in the repo. I plan on moving the data into MotherDuck and rebuilding the app to use that as the data source. A secondary app will need to be built to collect new usernames to add to the database.

### Board Game Geek Analysis
[Repo](https://github.com/Deniedpluto/bgg-dashboard)

Data for this project is pulled from another GitHub repo mainted by beefsack. The data is pulled down to form a subset of historical data that dates back to 2016. This data is transformed using a series of R Scripts that prep the data for dashboard. The final R Script pulls the current data from the BGG API to provide the most up to date information. The dashboard then can be refreshed to show the current data. A set of scripts for pulling and parsing review data also exist, but are not currently being run.

### Board Game Plays
[Repo](https://github.com/Deniedpluto/BoardGamePlays)

The board game plays data comes from the [BGStats app](https://www.bgstatsapp.com/). This is exported from the app as a json file and then parsed into (mostly) normalized tables in parquet format by a python script then loaded into Motherduck.