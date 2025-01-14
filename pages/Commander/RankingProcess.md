---
title: Commander Deck Ranking Process
sidebar_position: 4
---

### The Background

The initial system I implemented was a modification of Elo rating system. You can see the implementation of it in my [GitHub](https://github.com/Deniedpluto/MTG-Battle-Loggger/blob/main/MultiEloR.R). Despite the mathematical soundness, the output left me wanting more as it varied too highly. While it could have accounted for this by dropping the K value, I wanted to maintain a close parity to [guildpact](https://guildpactapp.com/) - the app we were using to track our games.

The new system I created was inspired by the [swiss tournament system](https://en.wikipedia.org/wiki/Swiss-system_tournament) used in magic events as well as chess. I had also done some work in using the bayesian mean for rating systems with unequal observations and I thought this would be a good fit for the system I wanted to create.

### The System

My system takes into account 3 attributes of a deck:
1. The win rate of the deck
2. The win rate of the decks it has faced
3. The number of games played

The win rate of the deck is a simple calculation of the the number of wins divided by the number of games played.

The win rate of the decks it has faced is a bit more complicated. I take the unique list of all the decks that the deck has faced and divide the total wins by these decks by the total number of matches these decks have played.

The number of games played is used in the [bayesian average](https://en.wikipedia.org/wiki/Bayesian_average) calculation to account for decks with different numbers of games played. The formula is simple - the weight of the deck is equal to the number of matches this deck has played divided by the average number of matches all decks have played plus the number of matches this deck has played. This means that decks with less games are pulled towards the average while decks with more games have their strength pulled towards their actual win rate.

To pull this all together I multiply the win rate of the deck by the win rate of the decks it has faced to get a decks raw strength. I then take the weight of the deck described above and multiply the deck's raw strength by it and then add the product of the invserse of the weight by the average raw strength of all decks. This gives me the bayesian average of the decks strength. I then standardize this by subtracting the average strength of all decks and dividing by the standard deviation of all decks.

### The Variables
- WR = Deck Win Rate
- WRA = Deck Win Rate Against
- P = Number of games played
- A(P) = Average number of games played
- W = Weight of the deck
- STR = Raw Strength
- A(STR) = Average Raw Strength
- BSTR = Bayes Strength

### The Formulas
- STR = WR \* WRA
- W = P / (A(P) + P)
- BSTR = (STR \* W) + (A(STR) \* (1 - W))


