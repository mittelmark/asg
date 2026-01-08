---
title: "snha - Application for the St. Nicolas House Algorithm"
shorttitle: "St. Nicolas App"
author: 
- Detlef Groth, University of Potsdam
date: 2022-02-16
---

## <a name="toc">Table of Contents</a>

  * [Table of Contents](#toc)
  * [Introduction](#intro)  
  * [Data Preparation](#dataprep)
  * [Data Selection](#datasel)
  * [Analysis](#analysis)
  * [Analysis Export](#export)
  * [Demo Data](#demo)
  * [Summary](#summary)
  * [Changes](#changes)
  * [Packages](#packages)  
  * [TODO](#todo)  
  * [License](#license)
  
-----

## <a name="intro">Introduction</a>

The application provides a graphical user interface for the St. Nicolas House
Algorithm. The algorithm basically finds variables where correlations between
the variables are decreasing in the same manner for forwad and reverse ordered
variables. To give an example assume we have the variables *A*, *B* and *C*: 
if the forward ordering *r(A,B)* > *r(A,C)* and in the reverse *r(C,B)* > *r(C,A)*
we have an association chain.

For a detailed background on the algorithm have a look at the following two papers:

  * Groth, D., Scheffler, C., & Hermanussen, M. (2019). Body height in stunted Indonesian children depends directly on parental education and not via a nutrition mediated pathway-Evidence from tracing association chains by St. Nicolas House Analysis. Anthr Anz, 76(5), 445-451.
  * Hermanussen, M., Aßmann, C., & Groth, D. (2021). Chain Reversion for Detecting Associations in Interacting Variables - St. Nicolas House Analysis. Int J Env Res Pub Health, 18(4), 1741.

There exists a R package for the algorithm which will be relased to the CRAN
repository quite soon. For researches which are not R users the graphical
user interface provided with this package is an alternative to create networks
of interacting variables using a standard open and click interface. 

The workflow of the application consists actually from the following steps.

  * prepare your data in an Excel or Tab file
  * open a  Excel or Tab file with the data
  * select the appropiate columns for analysis 
  * please note that all column names will be abbreviated to the first 5 letters of the column names to allow correct display in the graph
  * perform the analysis with some standard settings (Pearson correlation, p-value thresold 0.05 or 0.1 usually)
  * export the analysis to an Excel file

In the following sections we will describe the analysis.

-----

## <a name="datapre">Data Preparation</a>

You might start with the demo data. Before you analyse your own data. For a
look on how to work with the demo data have a look a the [Demo Data](#demo)
section.

The application can process Excel-Data in the format *xlsx* and tabulated
files where columns are separated by tab stops and the first row contains the
column headers. In Excel files all tab sheets can be used to read in data.
Please use short column names which should be placed in the first row. The
column names should be without special symbols and spaces. Remove any formatting from the files in case of problems.
For the display in the network visualization only the first 5 letters and numbers of the column
names will be used. Column names should not start with numbers.

-----

## <a name="datasel">Data Selection</a>

The Excel or the tab files can be loaded using the "File Open" button or the
"File-Open File" menu entry. The first 200 lines will be displayed thereafter
in the table widget. You can thereafter select and unselect the columns by
clicking on the column. Visual indicators in the column headers will confirm
if a column is selected (green checkmark) or unselect (red cross symbol).
After you selected the columns you can process the data by switching to the
*Analysis* tab.

![](snappshot-01s.png)

Right of the "Select Sheet" combobox is as well a "Filter" entry field where
you can add logical expressions using the Sytnax "colname > value" supported operators are here greater >, smaller <, equality == and unequality !=. Several expressions can be combined with the ampersand sign "&" for the AND operator and the pipe sign "|" for the OR operator. Here an example for the swiss data set.

"Fertility > 70 and Examination < 20" would only show and use data with
Fertility values greater than 70 and Examination values samller than 20.
Usually these logical expressions should be used for qualitative data like sex where we have mostly only two values.


-----

## <a name="analysis">Analysis</a>

Therafter you switch to the *Analysis* tab of the application. Just use the
default settings here *Pearson* correlation and a p-value threshold of 0.05.
And press the analyze button at the lower left. You analyis is shown on the
image widget on top. Please note, that even if the image quality looks rather
poor on some systems, by exporting the image using the save button on top you can create high
quality graphics in the PDF format. 

You can play around with the analysis options at the bottom, all graphs will
be saved. Usually however the settings "Pearson" or "Spearman" and a p-value threshold of 0.05
are recommended. If you like to change the layout just press the tool button
on the lower left. There are as well layout options, such as:

  * 'sam' - non-metric MDS on the graph data, i.e. on the adjacency matrix, 
  * 'samd' - non metric MDS on the data itself,
  * 'mds' - metric MDS on the graph data,
  * 'mdsd' - metric MDS on the data itself,  
  * 'circle' - circular layout
  
More layout options such as Fruchterman-Reingold or star layout might be added in the future.
The image of the plot size can be adjusted by using the arrow buttons at
the bottom of the graph. Please note, that if you choose the Kendall-Tau method to calculate the correlations
R will try to install a fast implementation of this algorithm using the *pcaPP* package.
To show the the correlations between connected nodes you can use the checkbox "Correlations" on the right.

There is as well a bootstrap checkbox which does a resampling of the samples
with replacement. Stable edges should be found in most of the resamplings. The
line type encodes how often a edge was found, dotted lines indicate edges
which were found in 25-50 percent of the resamplings, broken lines indicate
edges which were found in 50-75 percent of the resamplings and solid lines
indicate edges found in more than 75 percent of the resamplings. In empirical
investigations we observed that random data produce usually edges which appear
in less than 10 percent of the resamplings (Hake 2022, personal
communication). So we can consider edges which appear in more than 25 percent
of the resamplings as significant.

There is a well a checkbox if you want to check nodes which are not to in
association chains for significant pairwise correlations (Singlecheck). 

There are further other visualizations available so for pairwise correlations
(Cor), 

  * MDScor1 using correlation distance with formula *d(a,b) = 1-abs(r(a,b))* where highly negatively correlated variables have a low distance, they are displayed closely to each other 
  * MDScor2 using MDS using correlation distance with formula *d(a,b) = (1-r(r,ab))/2* where negatively correlated variables are far apart from each other
  * PCAvar PCA scores for the variables (PCAvar) 
  * PCAsam PCA scores for the samples (PCAsam) 
  * Clustering analysis using correlation distance as *d(a,b) = 1 - abs (r(a,b))*.

For the SNHA  algorithm  it is as well  possible to change the  coloring.  For
example you might change the default salmon color to skyblue. Or you might use
use the harmonic  centrality  measure to display highly  centralized  nodes in
red, and  unconnected  or marginal nodes with light blue. A value of 1 for the
harmonic  centrality  would mean that this node is directly  connected  to all
other  nodes of the  graph,  so all  shortest  path for this  nodes  are 1. In
contrast a value of zero for a node mean, that this node is not  connected  to
any other node. For more  information on the harmonic mean have a look at this
blog post by symbio5.nl:

https://symbio6.nl/en/blog/analysis/harmonic-centrality

**Hint:**  
You can export all the plots by  clicking on the save button on the
left in the upper button bar. All plots will be then saved in a PDF
file. 

![](snappshot-02s.png)

-----

## <a name="export">Analysis Export</a>

The analysis with the information about the graph and the data as well some
PCA analysis results can be saved using the "File->Save Report" menu entry. The resulting Excel file contains the following sheets:

  * "Adjacency matrix" - which node/variable is connect with which, an entry of 1 means they are connecred
  * "Cor pearson/spearman" - the correlation values for all variable pairs
  * "Cor p-values" - the correlation p-values for all variable pairs
  * "Chains" - the found St. Nicolas chains forming the final graph
  * "Settings" - the used settings to perform the analysis
  * "Data" - the input data for the algorithm  
  * "Centrality" - the degree and harmonic centrality values for all nodes
  * "Cor Plots" - the pairwise correlation plot
  * "Asg Plot" - the graph plot based on the association matrix
  * "Harmonic Plot" - the graph plot based on the  association  matrix  with color codes related to the harmonic centrality
  * "PCAPlot*" - plot of the PCA for the scaled variables
  * "PCAImportance" - the importance values for the PC's
  * "PCARotation" - the contributions of the variables to the new components
  * "PCAData" - the scaled data used for the PCA, NA's where imputed using the median before

-----

## <a name="demo">Demo Data</a>

You can load some demo data using the menu point *Demo*. There are currently
two data sets available:

  * the dataset *swiss* containg standardized fertility
measure and socio-economic indicators for each of 47 French-speaking provinces
of Switzerland at about 1888.
  * the dataset *birthwt* from the MASS library with 189 rows and 10 columns.  The data
were collected at Baystate Medical Center, Springfield, Mass during 1986.
  * the dataset *environmental* from the lattice package with daily measurements of ozone concentration, wind speed, temperature and solar radiation in New York City from May to September of 1973.
  * the *Boston* dataset from the MASS library with 506 rows and 14 columns
  * the dataset *NHANES* from the NHANES library with 7832 rows and 25 columns. 
The data  are survey data collected by the US National Center for Health  Statistics (NCHS) between 1999 and 2002. This data requires
the installation of the NHANES data. The installation will be requested if you request the data for the first time.  

The *swiss* and the *birthwt* datasets will have a last column called *Rand* which just contains random data.

Load one of the datasets using the menu point below the *Demo* menu entry.

You can select and deselect the columns by clicking on the column. On the top
there is an indicator either a checkmark or a cross, to indicate if the column
is currently selected. You should with the demo column leave all columns checked.

Therafter you switch to the *Analysis* tab of the application. Just use the
default settings here *Pearson* correlation and a p-value threshold of 0.05.
And press the analyze button at the lower left. You analyis is sown on the
image widget on top. Please note, that even if the image quality looks rather
low, by exporting the image using the save button on top you can create high
quality graphics. 

You can play around with the analysis options at the bottom, all graphs will
be saved. Usually however the settings "Pearson" and p-value threshold of 0.05 are recommended.

To export an analysis finally, use the menu point *File-Save Report* and save
the analysis as an Excel file.

Here are the column descriptions:

**birthwt:**

  * age - mother's age in years
  * lwt - mother's weight in pounds at last menstrual period
  * race - renamed to ethn mother status, 1 = white, 2 = black, 3 = other
  * smoke - smoking status during pregnancy, 0 = no, 1 = yes
  * ptl - number of previous premature labours
  * ht - history of hypertension, 0 = no, 1 = yes
  * ui - presence of uterine irritability, 0 = no, 1 = yes
  * ftv - number of physician visits during the first trimester
  * bwt - birth weight of the child in grams

**Boston:**

  * crim - per capita crime rate by town
  * zn - proportion of residential land zoned for lots over 25,000 sq.ft
  * indus - proportion of non-retail business acres per town
  * chas - Charles River dummy variable (= 1 if tract bounds river; 0 otherwise).
  * nox - nitrogen oxides concentration (parts per 10 million)
  * rm - average number of rooms per dwelling
  * age - proportion of owner-occupied units built prior to 1940
  * dis - weighted mean of distances to five Boston employment centres
  * rad -  index of accessibility to radial highways
  * tax - full-value property-tax rate per 10,000
  * ptratio -  pupil-teacher ratio by town
  * black - 1000(Bk - 0.63)^2 where Bk is the proportion of blacks by town
  * lstat - lower status of the population (percent)
  * medv - median value of owner-occupied homes in 1000s

**environmental:**

  * ozone - average ozone concentration (of hourly measurements) of in parts per billion
  * radiation - solar radiation (from 08:00 to 12:00) in langleys
  * temperature - maximum daily emperature in degrees Fahrenheit
  * wind - average wind speed (at 07:00 and 10:00) in miles per hour

**swiss:**

  * Fertility - common standardized fertility measure
  * Agriculture - percent of males involved in agriculture as occupation 
  * Examination - percent of draftees receiving highest mark on army examination 
  * Education  -  percent of education beyond primary school for draftees
  * Catholic   - percent of catholic
  * Infant.Mortality - live births who live less than one year 

**NHANES:**

These are resampling data from 2009-2012, please see the package documentaion
to find out what all the variables are standing for. Not all variables are used as demo data. Here is one online link to read the documentation and to find more about the variable names:

https://cran.r-project.org/web/packages/NHANES/NHANES.pdf
  
-----

## <a name="summary">Summary</a>

The application provides the major facilities to apply the St. Nicolas House
Algorithm to your data and to store the analysis and the major graphics on
your system. If you use the application please cite the URL at github and the following two papers:

  * Groth, D., Scheffler, C., & Hermanussen, M. (2019). Body height in stunted Indonesian children depends directly on parental education and not via a nutrition mediated pathway-Evidence from tracing association chains by St. Nicolas House Analysis. Anthr Anz, 76(5), 445-451.
  * Hermanussen, M., Aßmann, C., & Groth, D. (2021). Chain Reversion for Detecting Associations in Interacting Variables - St. Nicolas House Analysis. Int J Env Res Pub Health, 18(4), 1741.

-----

## <a name="changes">Changes</a>

**Version 0.3:**

  * load recent file
  * adding correlation plot in plot area
  * adding save images as png directly

**Version 0.4:**

  * adding nhanes.tab as demo 
  * building standalone Rscripts  

**Version 0.5.0:**

  * adding installation of NHANES and pcaPP (for cor.fk) libraries

**Version 0.5.1:**

  * fix for  wrong column names
  * adding correlation values is possible to plot
  * selecting layout sam, samd (sammon on data), mds, mdsd (MDS on data) and circle

**Version 0.6.0 - Summerschool 2022:**

  * more example datasets Boston (library MASS), environmental (library lattice)
  * size of node text and in correlation plot is now adjustable
  * single check for isolated nodes is now available
  * more plotting methods for PCA (of variables and samples) and for clustering

**Version 0.7.0 - Aschauhof Autumn 2022:**

  * adding data filtering
  * two MDS distances can be used
  * correlation values can be shown on the graph
    
**Version 0.7.1 - October 2022**

  * adding csv loading support
  * adding PCA imputation

**Version 0.8.0 - January, 7th 2026**
  
  * adding support for harmonic centrality in node coloring
  * fixing Excel report saving
  * redesign of project and new Github project at
    https://github.com/mittelmark/asg for GUI and package
    
**Version 0.8.1 - January, Xth 2026**

  * automatic removal of variables with zero variance in the analysis

-----

## <a name="packages">Packages</a>

  * base64 - Jeroen Ooms (2016). base64: Base64 Encoder and Decoder. R package version 2.0. 
    https://CRAN.R-project.org/package=base64
  * NHANES - Randall Pruim (2015). NHANES: Data from the US National Health and Nutrition Examination Study. R package version 2.1.0.
    https://CRAN.R-project.org/package=NHANES
  * openxlsx - Philipp Schauberger and Alexander Walker (2021). openxlsx: Read, Write and Edit xlsx Files. R package version 4.2.4.
    https://CRAN.R-project.org/package=openxlsx
  * pcaPP -  Peter Filzmoser, Heinrich Fritz and Klaudius Kalcher (2021). pcaPP: Robust PCA by Projection Pursuit. R package version 1.9-74.
    https://CRAN.R-project.org/package=pcaPP
    
-----

## <a name="todo">TODO</a>

  * rs - threshold for r-square value
  * bootstrap - edge probabilities (done)
  * layout circle, sam, star (with most connected node in the center, partially done)
  * edit window to do data selection age >= 20 & age <= 30
  * pdf/png plot with settings at the margin spearman, p-val < 0.05 etc. (done)
  
-----

## <a name="license">License</a>

Copyright 2021-2022, Dr. Detlef Groth, University of Potsdam

Permission is hereby  granted, free of charge, to any person  obtaining a copy
of this software and associated  documentation files (the "Software"), to deal
in the Software without  restriction,  including without limitation the rights
to use, copy, modify,  merge,  publish,  distribute,  sublicense,  and/or sell
copies  of the  Software,  and to  permit  persons  to whom  the  Software  is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE  SOFTWARE IS PROVIDED  "AS IS", WITHOUT  WARRANTY OF ANY KIND,  EXPRESS OR
IMPLIED,  INCLUDING  BUT NOT  LIMITED TO THE  WARRANTIES  OF  MERCHANTABILITY,
FITNESS FOR A PARTICULAR  PURPOSE AND  NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS  OR  COPYRIGHT  HOLDERS  BE LIABLE  FOR ANY  CLAIM,  DAMAGES  OR OTHER
LIABILITY,  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
  







