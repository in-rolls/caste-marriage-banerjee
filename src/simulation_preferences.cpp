#include <Rcpp.h>
#include <algorithm>
#include <numeric>
#include <vector>
using namespace Rcpp;

// Translated scalar feature expressions from algorithm_new.m. Inputs remain in
// the original CSV column order; each feature is stored at single precision.
std::vector<float> score_candidates(NumericMatrix candidates,
                                    NumericVector chooser, NumericVector beta,
                                    bool bride_side, bool correct_residence,
                                    bool correct_bride_handoff = false) {
  int count = candidates.nrow();
  std::vector<float> scores(count);
  for (int row = 0; row < count; ++row) {
    float features[58] = {};
    if (bride_side) {
      features[0] = candidates(row, 4) == 2;
      features[1] = candidates(row, 4) == 3;
      features[2] = candidates(row, 4) == 4;
      features[3] = candidates(row, 4) == 5;
      features[4] = candidates(row, 4) == 6;
      features[5] = candidates(row, 4) == 7;
      features[6] = candidates(row, 4) == 8;
      features[10] = candidates(row, 5);
      features[22] = candidates(row, 9);
      features[28] = candidates(row, 11);
      features[30] = candidates(row, 16) == 2;
      features[31] = candidates(row, 16) == 3;
      features[32] = candidates(row, 16) == 4;
      features[33] = candidates(row, 16) == 5;
      features[34] = candidates(row, 16) == 6;
      features[37] = candidates(row, 17);
      features[38] = candidates(row, 21);
      features[39] = candidates(row, 20);
      features[40] = candidates(row, 22);
      features[41] = candidates(row, 18);
      features[43] = candidates(row, 23);
      features[44] = candidates(row, 24);
      features[45] = candidates(row, 25);
      features[46] = candidates(row, 1) == 2;
      features[48] = candidates(row, 8);
      features[50] = candidates(row, 0);
      features[52] = candidates(row, 6);
      features[54] = candidates(row, 26);
      features[55] = candidates(row, 27);
      features[56] = 1;
      features[7] =
          candidates(row, 30) == chooser[30] ||
          (candidates(row, 30) == 1 && chooser[4] == 1) ||
          (candidates(row, 30) == 18 && chooser[4] == 2) ||
          (candidates(row, 30) == 9 && chooser[4] == 3) ||
          (candidates(row, 30) == 20 && chooser[4] == 4 && chooser[30] != 24 &&
           chooser[30] != 83 && chooser[30] != 87 && chooser[30] != 105) ||
          (candidates(row, 30) == 16 &&
           (chooser[30] == 17 || chooser[30] == 100)) ||
          (candidates(row, 30) == 25 &&
           ((chooser[30] >= 26 && chooser[30] <= 30) || chooser[30] == 35 ||
            chooser[30] == 37 || chooser[30] == 39 || chooser[30] == 100 ||
            chooser[30] == 105 || chooser[30] == 107)) ||
          (candidates(row, 30) == 31 &&
           (chooser[30] == 32 || chooser[30] == 33 || chooser[30] == 40 ||
            chooser[30] == 41 || chooser[30] == 85)) ||
          (candidates(row, 30) == 34 && chooser[30] == 35) ||
          (candidates(row, 30) == 36 && chooser[30] == 37) ||
          (candidates(row, 30) == 38 && chooser[30] == 39) ||
          (candidates(row, 30) == 42 && chooser[30] == 43) ||
          (candidates(row, 30) == 44 &&
           (chooser[30] == 45 || chooser[30] == 46)) ||
          (candidates(row, 30) == 53 && chooser[30] == 54) ||
          (candidates(row, 30) == 56 && chooser[30] == 57) ||
          (candidates(row, 30) == 58 &&
           (chooser[30] >= 59 && chooser[30] <= 63)) ||
          (candidates(row, 30) == 79 && chooser[4] == 8) ||
          (chooser[30] == 1 && candidates(row, 4) == 1) ||
          (candidates(row, 4) == 2 && chooser[30] == 18) ||
          (candidates(row, 4) == 3 && chooser[30] == 9) ||
          (candidates(row, 4) == 4 && chooser[30] == 20 &&
           candidates(row, 30) != 24 && candidates(row, 30) != 83 &&
           candidates(row, 30) != 87 && candidates(row, 30) != 105) ||
          ((candidates(row, 30) == 17 || candidates(row, 30) == 100) &&
           chooser[30] == 16) ||
          (chooser[30] == 25 &&
           ((candidates(row, 30) >= 26 && candidates(row, 30) <= 30) ||
            candidates(row, 30) == 35 || candidates(row, 30) == 37 ||
            candidates(row, 30) == 39 || candidates(row, 30) == 100 ||
            candidates(row, 30) == 105 || candidates(row, 30) == 107)) ||
          (chooser[30] == 31 &&
           (candidates(row, 30) == 32 || candidates(row, 30) == 33 ||
            candidates(row, 30) == 40 || candidates(row, 30) == 41 ||
            candidates(row, 30) == 85)) ||
          (candidates(row, 30) == 35 && chooser[30] == 34) ||
          (candidates(row, 30) == 37 && chooser[30] == 36) ||
          (candidates(row, 30) == 39 && chooser[30] == 38) ||
          (candidates(row, 30) == 43 && chooser[30] == 42) ||
          (chooser[30] == 44 &&
           (candidates(row, 30) == 45 || candidates(row, 30) == 46)) ||
          (candidates(row, 30) == 54 && chooser[30] == 53) ||
          (candidates(row, 30) == 57 && chooser[30] == 56) ||
          (chooser[30] == 58 &&
           (candidates(row, 30) >= 59 && candidates(row, 30) <= 63)) ||
          (candidates(row, 4) == 8 && chooser[30] == 79);
      features[8] = (candidates(row, 4) - chooser[4]) *
                    (candidates(row, 4) < chooser[4]) *
                    (candidates(row, 4) != 0);
      features[9] = (candidates(row, 4) - chooser[4]) *
                    (candidates(row, 4) > chooser[4]) * (chooser[4] != 0);
      features[11] = chooser[5] * features[10];
      features[12] = chooser[28] * features[7];
      features[13] = chooser[28] * (features[8] + features[9]);
      features[14] = chooser[28] * features[10];
      features[15] = chooser[29] * features[7];
      features[16] = chooser[29] * (features[8] + features[9]);
      features[17] = chooser[29] * features[10];
      features[18] = chooser[9] * candidates(row, 2);
      features[19] = features[22] * chooser[2];
      features[20] = (chooser[9] != 1 && features[22] != 1) *
                     ((candidates(row, 2) - chooser[2]));
      features[21] = features[20] * features[20];
      features[23] = chooser[9] * features[22];
      features[24] = chooser[11] * candidates(row, 10);
      features[25] = features[28] * chooser[10];
      features[26] = (chooser[11] != 1 && features[28] != 1) *
                     ((candidates(row, 10) - chooser[10]));
      features[27] = features[26] * features[26];
      features[29] = chooser[11] * features[28];
      features[35] = (chooser[18] != 1 && features[41] != 1) *
                     (candidates(row, 16) == chooser[16]);
      features[36] = (chooser[18] != 1 && features[41] != 1) *
                     (candidates(row, 16) > chooser[16]);
      features[42] = chooser[18] * features[41];
      features[47] = (features[48] != 1 && chooser[8] != 1) *
                     (chooser[1] == candidates(row, 1));
      features[49] = chooser[8] * features[48];
      features[51] =
          (features[52] != 1 && chooser[6] != 1) * (features[50] == chooser[0]);
      features[53] = chooser[6] * features[52];
    } else {
      features[0] = candidates(row, 4) == 2;
      features[1] = candidates(row, 4) == 3;
      features[2] = candidates(row, 4) == 4;
      features[3] = candidates(row, 4) == 5;
      features[4] = candidates(row, 4) == 6;
      features[5] = candidates(row, 4) == 7;
      features[6] = candidates(row, 4) == 8;
      features[10] = candidates(row, 5);
      features[22] = candidates(row, 9);
      features[28] = candidates(row, 11);
      features[30] = candidates(row, 16) == 2;
      features[31] = candidates(row, 16) == 3;
      features[32] = candidates(row, 16) == 4;
      features[33] = candidates(row, 16) == 5;
      features[34] = candidates(row, 16) == 6;
      features[37] = candidates(row, 17);
      features[38] = candidates(row, 21);
      features[39] = candidates(row, 20);
      features[40] = candidates(row, 22);
      features[42] = candidates(row, 18);
      features[43] = candidates(row, 23);
      features[44] = candidates(row, 3);
      features[45] = candidates(row, 12);
      features[46] = candidates(row, 1) == 2;
      features[48] = candidates(row, 8);
      features[50] = candidates(row, 0);
      features[52] = candidates(row, 6);
      features[54] = candidates(row, 14);
      features[55] = candidates(row, 13);
      features[56] = candidates(row, 15);
      features[57] = 1;
      features[7] =
          candidates(row, 30) == chooser[30] ||
          (candidates(row, 30) == 1 && chooser[4] == 1) ||
          (candidates(row, 30) == 18 && chooser[4] == 2) ||
          (candidates(row, 30) == 9 && chooser[4] == 3) ||
          (candidates(row, 30) == 20 && chooser[4] == 4 && chooser[30] != 24 &&
           chooser[30] != 83 && chooser[30] != 87 && chooser[30] != 105) ||
          (candidates(row, 30) == 16 &&
           (chooser[30] == 17 || chooser[30] == 100)) ||
          (candidates(row, 30) == 25 &&
           ((chooser[30] >= 26 && chooser[30] <= 30) || chooser[30] == 35 ||
            chooser[30] == 37 || chooser[30] == 39 || chooser[30] == 100 ||
            chooser[30] == 105 || chooser[30] == 107)) ||
          (candidates(row, 30) == 31 &&
           (chooser[30] == 32 || chooser[30] == 33 || chooser[30] == 40 ||
            chooser[30] == 41 || chooser[30] == 85)) ||
          (candidates(row, 30) == 34 && chooser[30] == 35) ||
          (candidates(row, 30) == 36 && chooser[30] == 37) ||
          (candidates(row, 30) == 38 && chooser[30] == 39) ||
          (candidates(row, 30) == 42 && chooser[30] == 43) ||
          (candidates(row, 30) == 44 &&
           (chooser[30] == 45 || chooser[30] == 46)) ||
          (candidates(row, 30) == 53 && chooser[30] == 54) ||
          (candidates(row, 30) == 56 && chooser[30] == 57) ||
          (candidates(row, 30) == 58 &&
           (chooser[30] >= 59 && chooser[30] <= 63)) ||
          (candidates(row, 30) == 79 && chooser[4] == 8) ||
          (chooser[30] == 1 && candidates(row, 4) == 1) ||
          (candidates(row, 4) == 2 && chooser[30] == 18) ||
          (candidates(row, 4) == 3 && chooser[30] == 9) ||
          (candidates(row, 4) == 4 && chooser[30] == 20 &&
           candidates(row, 30) != 24 && candidates(row, 30) != 83 &&
           candidates(row, 30) != 87 && candidates(row, 30) != 105) ||
          ((candidates(row, 30) == 17 || candidates(row, 30) == 100) &&
           chooser[30] == 16) ||
          (chooser[30] == 25 &&
           ((candidates(row, 30) >= 26 && candidates(row, 30) <= 30) ||
            candidates(row, 30) == 35 || candidates(row, 30) == 37 ||
            candidates(row, 30) == 39 || candidates(row, 30) == 100 ||
            candidates(row, 30) == 105 || candidates(row, 30) == 107)) ||
          (chooser[30] == 31 &&
           (candidates(row, 30) == 32 || candidates(row, 30) == 33 ||
            candidates(row, 30) == 40 || candidates(row, 30) == 41 ||
            candidates(row, 30) == 85)) ||
          (candidates(row, 30) == 35 && chooser[30] == 34) ||
          (candidates(row, 30) == 37 && chooser[30] == 36) ||
          (candidates(row, 30) == 39 && chooser[30] == 38) ||
          (candidates(row, 30) == 43 && chooser[30] == 42) ||
          (chooser[30] == 44 &&
           (candidates(row, 30) == 45 || candidates(row, 30) == 46)) ||
          (candidates(row, 30) == 54 && chooser[30] == 53) ||
          (candidates(row, 30) == 57 && chooser[30] == 56) ||
          (chooser[30] == 58 &&
           (candidates(row, 30) >= 59 && candidates(row, 30) <= 63)) ||
          (candidates(row, 4) == 8 && chooser[30] == 79);
      features[8] = (candidates(row, 4) - chooser[4]) *
                    (candidates(row, 4) > chooser[4]) * (chooser[4] != 0);
      features[9] = (candidates(row, 4) - chooser[4]) *
                    (candidates(row, 4) < chooser[4]) *
                    (candidates(row, 4) != 0);
      features[11] = chooser[5] * features[10];
      features[12] = chooser[28] * features[7];
      features[13] = chooser[28] * (features[8] + features[9]);
      features[14] = chooser[28] * features[10];
      features[15] = chooser[29] * features[7];
      features[16] = chooser[29] * (features[8] + features[9]);
      features[17] = chooser[29] * features[10];
      features[18] = chooser[9] * candidates(row, 2);
      features[19] = features[22] * chooser[2];
      features[20] = (chooser[9] != 1 && features[22] != 1) *
                     ((chooser[2] - candidates(row, 2)));
      features[21] = features[20] * features[20];
      features[23] = chooser[9] * features[22];
      features[24] = chooser[11] * candidates(row, 10);
      features[25] = features[28] * chooser[10];
      features[26] = (chooser[11] != 1 && features[28] != 1) *
                     ((chooser[10] - candidates(row, 10)));
      features[27] = features[26] * features[26];
      features[29] = chooser[11] * features[28];
      features[35] = (chooser[18] != 1 && features[42] != 1) *
                     (candidates(row, 16) == chooser[16]);
      features[36] = (chooser[18] != 1 && features[42] != 1) *
                     (candidates(row, 16) < chooser[16]);
      features[41] = chooser[18] * features[42];
      features[47] = (features[48] != 1 && chooser[0] != 1) *
                     (chooser[8] == candidates(row, 1));
      features[49] = chooser[8] * features[48];
      features[51] =
          (features[52] != 1 && chooser[6] != 1) * (features[50] == chooser[0]);
      features[53] = chooser[6] * features[52];
      if (correct_residence)
        features[47] = (candidates(row, 8) != 1 && chooser[8] != 1) *
                       (chooser[1] == candidates(row, 1));
    }
    if (bride_side && correct_bride_handoff) {
      for (int column : {8, 9, 13, 16})
        features[column] = -features[column];
      std::swap(features[18], features[19]);
      std::swap(features[24], features[25]);
    }
    double score = 0;
    for (int column = 0; column < beta.size(); ++column)
      score += features[column] * beta[column];
    scores[row] = static_cast<float>(10000 * score);
  }
  return scores;
}

// [[Rcpp::export]]
NumericVector simulation_scores(NumericMatrix candidates, NumericVector chooser,
                                NumericVector beta, bool bride_side,
                                bool correct_residence = false,
                                bool correct_bride_handoff = false) {
  return wrap(score_candidates(candidates, chooser, beta, bride_side,
                               correct_residence, correct_bride_handoff));
}

// [[Rcpp::export]]
List simulation_preferences(NumericMatrix males, NumericMatrix females,
                            NumericVector beta_brides,
                            NumericVector beta_grooms,
                            bool correct_residence = false,
                            bool correct_bride_handoff = false) {
  const int n_men = males.nrow(), n_women = females.nrow();
  IntegerMatrix female_ranks(n_men, n_women), male_preferences(n_women, n_men);
  std::vector<double> mean_ranks(n_men, 0);
  std::vector<int> order_men(n_men), order_women(n_women);
  std::vector<std::vector<int>> tied_ranges(n_women);
  std::iota(order_men.begin(), order_men.end(), 0);
  for (int woman = 0; woman < n_women; ++woman) {
    if (woman % 100 == 0)
      checkUserInterrupt();
    auto scores = score_candidates(males, females(woman, _), beta_brides, true,
                                   false, correct_bride_handoff);
    std::iota(order_men.begin(), order_men.end(), 0);
    std::stable_sort(order_men.begin(), order_men.end(),
                     [&](int a, int b) { return scores[a] > scores[b]; });
    for (int rank = 0; rank < n_men; ++rank) {
      female_ranks(order_men[rank], woman) = rank + 1;
      mean_ranks[order_men[rank]] += rank + 1;
    }
    for (int begin = 0; begin < n_men;) {
      int end = begin + 1;
      while (end < n_men && scores[order_men[begin]] == scores[order_men[end]])
        ++end;
      if (end - begin > 1) {
        tied_ranges[woman].push_back(begin);
        tied_ranges[woman].push_back(end);
      }
      begin = end;
    }
  }
  std::iota(order_men.begin(), order_men.end(), 0);
  std::stable_sort(order_men.begin(), order_men.end(),
                   [&](int a, int b) { return mean_ranks[a] < mean_ranks[b]; });
  std::vector<int> male_position(n_men), rank_to_man(n_men);
  for (int rank = 0; rank < n_men; ++rank)
    male_position[order_men[rank]] = rank;
  // The original code reorders men before recomputing women's rankings. This
  // changes equal-score tie order even though the preference scores do not
  // change.
  for (int woman = 0; woman < n_women; ++woman) {
    for (int man = 0; man < n_men; ++man)
      rank_to_man[female_ranks(man, woman) - 1] = man;
    auto ranges = tied_ranges[woman];
    for (size_t range = 0; range < ranges.size(); range += 2) {
      int begin = ranges[range], end = ranges[range + 1];
      std::sort(
          rank_to_man.begin() + begin, rank_to_man.begin() + end,
          [&](int a, int b) { return male_position[a] < male_position[b]; });
      for (int rank = begin; rank < end; ++rank)
        female_ranks(rank_to_man[rank], woman) = rank + 1;
    }
  }
  for (int man = 0; man < n_men; ++man) {
    if (man % 100 == 0)
      checkUserInterrupt();
    auto scores = score_candidates(females, males(man, _), beta_grooms, false,
                                   correct_residence);
    std::iota(order_women.begin(), order_women.end(), 0);
    std::stable_sort(order_women.begin(), order_women.end(),
                     [&](int a, int b) { return scores[a] > scores[b]; });
    for (int rank = 0; rank < n_women; ++rank)
      male_preferences(rank, man) = order_women[rank] + 1;
  }
  return List::create(_["female_ranks"] = female_ranks,
                      _["male_preferences"] = male_preferences,
                      _["male_order"] = wrap(order_men));
}

// [[Rcpp::export]]
List simulation_match(IntegerMatrix male_preferences,
                      IntegerMatrix female_ranks) {
  const int n_men = male_preferences.ncol(), n_women = male_preferences.nrow();
  IntegerVector choice(n_men), husbands(n_women), next_rank(n_men);
  double proposals = 0;
  for (int initial_man = 0; initial_man < n_men; ++initial_man) {
    int man = initial_man;
    while (man >= 0) {
      int rank = next_rank[man]++;
      if (rank >= n_women)
        stop("A proposer exhausted the complete preference list");
      int woman = male_preferences(rank, man) - 1;
      int incumbent = husbands[woman] - 1;
      ++proposals;
      if (incumbent < 0 ||
          female_ranks(man, woman) < female_ranks(incumbent, woman)) {
        husbands[woman] = man + 1;
        choice[man] = woman + 1;
        if (incumbent >= 0)
          choice[incumbent] = 0;
        man = incumbent;
      }
      if (static_cast<long>(proposals) % 100000 == 0)
        checkUserInterrupt();
    }
  }
  double blocking_pairs = 0;
  for (int man = 0; man < n_men; ++man) {
    for (int rank = 0; rank < next_rank[man] - 1; ++rank) {
      int woman = male_preferences(rank, man) - 1;
      int incumbent = husbands[woman] - 1;
      if (incumbent < 0 ||
          female_ranks(man, woman) < female_ranks(incumbent, woman))
        ++blocking_pairs;
    }
  }
  return List::create(_["choice"] = choice, _["proposals"] = proposals,
                      _["blocking_pairs"] = blocking_pairs);
}
