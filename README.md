# R / Shiny penguins

Git a linear model with `Rscript` in a **Job**, and publish an interactive **R Shiny App**.

This project belongs to a Renku **hands-on workshop** at SDSC aiming to share how to create jobs and apps in Renku. Each participant submits a **Job** (non-interactive run) and publishes an **App** (public web app) from this repo.

> **Data rule:** Renku apps run only on **public** projects.

## What's inside

| Path | Role |
| --- | --- |
| `fit.R` | **Job**: `lm()` on a train split, prints coefficients, R² and test RMSE, saves the model |
| `app.R` | **App**: R Shiny explorer |
| `install.R` | Package list for builders that read it |
| `data/penguins.csv` | palmerpenguins data (CC0) |
| `Procfile` | One line that tells Renku how to start the app (`web:` binds `0.0.0.0` and `$RENKU_SESSION_PORT`) |

## Preparation
1. Fork the code repository `https://github.com/bethcg/renku-workshp-penguins`.
2. Create a new project in Renku with the following requirements:
- Data connector with a shared folder in your Polybox or Switchdrive account with **read/write** permissions. [Connect a shared folder to your project](https://docs.renkulab.io/en/latest/docs/users/data/guides/connect-data/connect-shared-switchdrive-or-polybox-folder-to-project/)
- Code repository to your fork. [Add a code repository](https://docs.renkulab.io/en/latest/docs/users/code/guides/add-code-repository-to-project/)
- Session launcher with Create from code on top of the requirements defined in the code repository. [Create an environment with custom packages](https://docs.renkulab.io/en/latest/docs/users/compute/environment/guides/create-environment-with-custom-packages-installed/)


## Exercise 1: Job

1. In your Renku project, add a launcher of type **Job**.
2. Choose **Create from code**. Select the code repository `renku-workshop-energy-forecasting` and set the command to:
   ```bash
   ["Rscript","renku-workshop-penguins/app/fit.R"]
   ```
Set the Job args to:
   ```bash
    ["--formula","body_mass_g ~ flipper_length_mm"]
   ```
3. Click **Submit**, keep the default resource class, and open the logs.
4. Submit again with a different argument and a bigger resource class:
Set the Job args to:
   ```bash
    ["--formula","body_mass_g ~ flipper_length_mm","--seed 2"]
   ```
5. Jobs don't keep files. Logs disappear when a job is dismissed, and finished jobs are removed after ~24 h. To keep results, point `--out` at a mounted data connector.

CLI alternative: `rnk launcher list --mode non-interactive` · `rnk job start --launcher <id>` · `rnk job logs <job-id>`.

## Exercise 2: App

A Shiny app where you choose axes and species, toggle a per-species linear fit, and see a table of species means.

1. Make sure the project is **public**.
2. Add a launcher of type **App**:
   - **Create from code** (stretch goal): point at this repo; Renku builds with buildpacks and runs the `Procfile`.
3. Click **Start** and wait until the status is *Live*, then click **Copy app URL** and share it.

## Run locally

```bash
Rscript fit.R --formula "body_mass_g ~ flipper_length_mm"
RENKU_SESSION_PORT=8000 R -e "shiny::runApp('app.R', host='0.0.0.0', port=8000)"
```

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| App stuck in Starting → Failed | Server must listen on `0.0.0.0` and `$RENKU_SESSION_PORT` |
| Start button greyed out | Project not public, build unfinished, no write access, or another app is already running in the project |
| Changes not visible | Stop and Start the app again after editing the launcher |
| Job results gone | Write to a data connector with `--out` |

## Data

`data/penguins.csv` is the [palmerpenguins](https://allisonhorst.github.io/palmerpenguins/) dataset (Horst, Hill & Gorman, CC0). It is committed so the image only needs `shiny`.

## Docs

- [Renku Jobs](https://docs.renkulab.io/en/latest/docs/users/compute/job/)
- [Renku Apps](https://docs.renkulab.io/en/latest/docs/users/compute/app/) · [Publish an app](https://docs.renkulab.io/en/latest/docs/users/compute/app/guides/host-app)