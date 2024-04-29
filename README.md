# Using Think-Aloud Data to Understand SRL in ITS

Supplementary repository of the manuscript "Using Think-Aloud Data to Understand Relations between Self-Regulation Cycle Characteristics and Student Performance in Intelligent Tutoring Systems" accepted as full paper to LAK '24.

## Citation

Borchers, C., Zhang, J., Baker, R. S., & Aleven, V. (2024). Using Think-Aloud Data to Understand Relations between Self-Regulation Cycle Characteristics and Student Performance in Intelligent Tutoring Systems. In *Proceedings of the 14th International Learning Analytics and Knowledge Conference* (LAK24). ACM. 
```
@inproceedings{borchers2024thinkaloud,
  title={Using Think-Aloud Data to Understand Relations between Self-Regulation Cycle Characteristics and Student Performance in Intelligent Tutoring Systems},
  author={Borchers, Conrad and Zhang, Jiayi and Baker, Ryan S and Aleven, Vincent},
  booktitle={LAK24: 14th International Learning Analytics and Knowledge Conference},
  doi={10.1145/3636555.3636911},
  url={https://doi.org/10.1145/3636555.3636911},
  year={2024}
}
```

## Folder structure

* `process-transcripts.ipynb`: Notebook to process think-aloud transcripts from Whisper AI based on native Zoom transcriptions and local transcriptions of audio files. Generates a file adding tutor log data context to transcripts for human labeling of utterances. The output of this process is available on [CMU DataShop][datashop]. The file itself cannot be executed as the raw dataset is not available due to PII.

* `setup-lak24.R`: All R setup code to create the analysis dataset from the human-labeled dataset from `process-transcripts.ipynb` which is on [CMU DataShop][datashop].

* `setup.sh`: A setup script which renames the datasets from [CMU DataShop][datashop] and runs the `setup-lak24.R` script if everything is present. If the output says that an error has occurred, do **NOT** run the below two files as they may fail to execute.

* `main-lak24.R` and `lak24-functions.R`: All R analysis code that takes the analysis dataset from `setup-lak24.R` to reproduce results for RQ1 and RQ2.

* `rq3-analysis.ipynb`: Analysis code to reproduce results for RQ3.

## Data availability

Data to reproduce all analyses conducted for this study can be requested via [CMU DataShop](https://pslcdatashop.web.cmu.edu/DatasetInfo?datasetId=5371).

[datashop]: https://pslcdatashop.web.cmu.edu/DatasetInfo?datasetId=5371

## Setup

There are two methods to run the analysis in this repository: [Development Containers (Dev Containers)](https://code.visualstudio.com/docs/devcontainers/containers) or running the codebase locally. Most of the setup process is handled for you using dev containers; however, it does require [Docker](https://www.docker.com/) to execute. The second method downloads the required software to your local machine; however, this is more prone to error as existing setups may cause the process to fail in one way or another. It is recommended to use the dev container route if you can get it working.

### Getting the Codebase

Clone this repository using one of the available options under the `<> Code` tab. If you do not know how to clone with `git`:

```bash
# e.g., git clone https://github.com/exampleuser/exampleproject.git
git clone <URL TO PROJECT>
```

### Getting the Datasets

First, open the [CMU Datashop][datashop] project webpage in your browser. To access the dataset, you will need to request access with an account on DataShop. You can create an account using your Google or GitHub account, whichever is easiest.

Once you have created an account, navigate back to the project webpage and click on the button `Request Access`. Provide your reasoning to access the dataset and click `Confirm`. You should receive an email once the PI approves the request; however, you can also check by seeing whether you can click the `Export` button on the project webpage.

Now that you have permission, you can get the first two CSVs needed for the project by clicking `Files (X)` where `X` is a number, and then clicking `Files (X)` again if no datasets are shown. Click the file names of the CSVs to download them: `lak24-coded-utterances.csv` and `transcripts-with-logdata-reference-lak24.csv`.

To get the final dataset, click the `Export` button. On the left hand side, make sure under `Shared Samples` that there is a checkbox next to `All Data` by clicking it. Then, click the `Export Transactions` button when it appears. Wait for the server to process your request, and then you should have `ds5371_tx_All_Data_7671_<timestamp>.txt`.

Put all three of these files in the root of the project folder on your machine:

```
srl-cycles-lak24
- .devcontainer
- renv
- lak24-coded-utterances.csv
- transcripts-with-logdata-reference-lak24.csv
- ds5371_tx_All_Data_7671_<timestamp>.txt
- main-lak24.R
- //...
```

### Method 1: Using Dev Containers

To use dev containers, you will need the following installed:

- [Docker](https://www.docker.com/products/docker-desktop/)
    - This provides a link to Docker Desktop for ease of use
- [Visual Studio Code](https://code.visualstudio.com/)
    - As of the writing of this README, only Visual Studio Code and the JetBrains suite support dev containers natively.
    - If you would like to use a different IDE or rich text editor, you will need to download and setup the [Dev Containers CLI](https://github.com/devcontainers/cli?tab=readme-ov-file#npm-install) in Node.js.
    - This method will use Visual Studio Code.

1. Open the project folder in Visual Studio Code by clicking `File -> Open Folder...` and then selecting the project folder. You should see `.devcontainer`, `renv`, `.gitignore` at the root level in the IDE.
2. Open up the extensions tab (the button on the left with four squares where the top right square is not directly part of the larger square) and install `ms-vscode-remote.vscode-remote-extensionpack` and `ms-azuretools.vscode-docker`. If you need to reload VSCode, do so.
3. Click the `><` symbol in the bottom left hand corner and select `Reopen in Container`.
4. Wait for the setup process to finish. This may take anywhere from 15-45 minutes depending on the speed of your machine.
5. Once the terminal says `Done. Press any key to close the terminal`, look at the line directly before it. If it says, `Setup successfully finished! You can now run...`, then you can open and run `main-lak24.R` and `rq3-analysis.ipynb`.
6. To run `main-lak24.R`, open the file and click the Play button in the upper right hand corner. This will open an R terminal and run all the executed code. The results should be saved into `.html` files.
7. To run `rq3-analysis.ipynb`, click the `Run All` button. If it asks you to select a kernel, click `Python Environments...` -> `Python 3.9.5 /usr/local/python/current/bin/python`. This option should have a star next to it along with the word `Recommended`. The results will be saved into `ans_sorted.csv` and anything significant will be reported in the output terminal.

### Method 2: Running the Code Locally

To run the code locally, you will need the following:

- R 4.2: [Windows](https://cran.r-project.org/bin/windows/base/old/4.2.0/R-4.2.0-win.exe), [Mac](https://cran.r-project.org/bin/macosx/base/R-4.2.0.pkg), [Linux](https://cran.r-project.org/src/base/R-4/R-4.2.0.tar.gz)
    - Any version of R 4.2 (e.g., 4.2.0-4.2.3) will work
- [Python 3.9](https://www.python.org/downloads/release/python-395/)
    - Any version of Python 3.9 (e.g., 3.9.0-3.9.19) will work
- [Jupyter Notebook Viewer](https://jupyter.org/)
    - Visual Studio Code and other plugin-based software will also work

> Note: If you are on Linux and would like to use the `setup.sh` script, you must make sure you have the `rename` package installed and `Rscript` on the PATH.
> ```bash
> # e.g. For debian users
> sudo apt-get update && sudo apt-get install -y --no-install-recommends rename
> ```

1. Install the python requirements from `requirements.txt` to your global Python instance or [virtual environment (recommended)](https://docs.python.org/3/library/venv.html#creating-virtual-environments) via:
```bash
# or py on Windows
python3 -m pip install -r requirements.txt
```
2. Once all the dependencies have been downloaded, install the `stopwords` dataset from `nltk` via:
```bash
# or py on Windows
python3 -m nltk.downloader stopwords
```
3. Open `R` and wait for `renv` to install itself. It should do so using the `.Rprofile` file. If not, run the following in the R terminal:
```R
install.packages("renv")
```
4. Once `renv` is installed, install the dependencies using the following command. If this step fails, follow the error message to install any missing packages before running the command again:
```R
renv::restore(prompt = FALSE)
```
5. Rename the transaction file `ds5371_tx_All_Data_7671_<timestamp>.txt` to `ds5371_tx_All_Data_7671.txt`.
6. Run the `setup-lak24.R` script either through the terminal or in R:
```bash
Rscript ./setup-lak24.R
```
```R
source("./setup-lak24.R")
```
7. Run `main-lak24.R` using your R environment.
8. Run `rq3-analysis.ipynb` using your Jupyter environment.

## FAQ

- `renv` won't download the libraries with a weird error "cannot edit staging" / R won't load tidyverse due to a missing file link

If you have installed everything correctly, this means that you still have some cache data from a previous R version that is interfering. You can clear this out but deleting `./renv/library`, `./renv/staging`, and the location of [`$RENV_PATHS_CACHE`](https://rstudio.github.io/renv/reference/paths.html). Then, run `renv::restore()` again.
