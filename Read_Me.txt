This batch of files allows users to replicate and extend the analysis in Jonathan Rothwell, "Biased News Media or Biased Readers? An Experiment in Trust" (New York Times, Upshot, Sept 26 2018).
https://www.nytimes.com/2018/09/26/upshot/biased-news-media-or-biased-readers-an-experiment-on-trust.html

Raw data can be downloaded from here
https://knight.app.box.com/s/wr5xetlgrvb6qhnqyren6fsdbt0jrvme

STATA users can directly import the .dta file from the relevant directory and run the analysis in the file "Upshot_Analysis_Public_Release.do". 
Non-STATA users can open this as a .txt file and view coding, most of which will be easy to understand for users of R, SPSS, or other programs.

Non-STATA users can use the file "NewsLens_Experiment1_Public_Release.csv" or the recoded version "Cleaned_for_Analysis_Data_NewsLens_Experiment1.csv".

1) "Variable list and dictionary.csv" lists the variables in the database and their labels.
2) For value labels, please refer to "Knight Gallup Newlens Survey Questionnaire and Value Labels.docx"
3) table output is organized as "bias_by___.csv" and has the following variables:

bias15ppt--bias defined as 1 if there is 1.5 percentage point absolute value difference or greater from blind-group mean; 0 if otherwise
low_bias--upward bound using 95% confidence interval
up_bias--lower bound using 95% confidence interval
N--number of ratings
nvals--number of unique raters
Zbias--standardized value of bias measure 
bias--value of bias measure
sebias15ppt--stanard error for bias using binary 1.5 ppt standard
seZbias--standard error for bias using standardized value

The other .csv files report collapsed summary statistics using the number of article-reviews as a weight. 

The regression results are also reported.

Contact Jonathan_Rothwell@gallup.com for questions or comments.