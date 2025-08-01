# Team Formation

## Code Climate Link
[Code Climate](https://codeclimate.com/github/phanijyothi11-tamu/team-formation)

## Deployed Heroku App
[Heroku App](https://teamformation-c5eaebc1d53b.herokuapp.com/)

---

## 1. Introduction
The "Team Formation" project is a web application designed to facilitate the users in creation of balanced and effective teams for academic projects. Developed using Ruby on Rails, this application allows users to input student data and specify criteria for team composition, such as skill sets and diversity factors. The system then processes this information to generate optimal team assignments that align with the defined parameters. By automating the team formation process, the application aims to enhance collaboration and project outcomes in educational settings.

---

## 2. Getting Started and Running Locally

### 2.1 Setup

#### Prerequisites

**Required Tools:**
- Ruby (version >= 2.7)
- Ruby on Rails (version >= 6.0)
- Git
- PostgreSQL (version >= 12)
- Node.js (version >= 12) and npm/yarn
- Bundler (Ruby gem for dependency management)
- A terminal/command line interface (CLI)

**Software:**
- A code editor such as Visual Studio Code, Atom, or RubyMine.
- A web browser for testing (Google Chrome recommended).

**Platform:**
- Compatible with Linux, macOS, or Windows (with WSL2 recommended for Windows users).

---

### Step-by-Step Instructions to Set Up the Development Environment

1. **Clone the Repository**
   ```bash
   git clone git@github.com:philipritchey/engr-102-team-formation.git
   cd engr-102-team-formation.git
   ```

2. **Install Ruby Version**
   ```bash
   rbenv install $(cat .ruby-version)
   rbenv local $(cat .ruby-version)
   ```

3. **Install Bundler**
   ```bash
   gem install bundler
   ```

4. **Install Ruby on Rails Dependencies**
   ```bash
   bundle config without production
   bundle install
   ```

5. **Install JavaScript Dependencies**
   ```bash
   yarn install
   ```

6. **Setup the Database**
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   bundle exec rails db:test:prepare
   ```

7. **Run Tests**
   ```bash
   bundle exec rspec
   bundle exec cucumber
   ```

8. **Seed the database**
   ```bash
   rails db:seed
   ```

9. **Create a Google OAuth client**
   [Go to Google cloud console](https://console.cloud.google.com/) and set up your app's OAuth client.

   **SAVE THE CREDENTIALS!** you need them in the next step.

   Add redirect URI `http://127.0.0.1:3000/auth/google_oauth2/callback`

10. **Generate a new master.key and add Google OAuth client id and secret to it**
   ```bash
   EDITOR="nano" rails credentials:edit
   ```

   Put the google client credentials in the Rails credential file:

   ```yaml
   google:
       client_id: ...your client id here...
       client_secret: ...your client secret here...
   ```


11. **Run the Server**
    ```bash
    rails server
    ```

12. **Access the Application Open your web browser and navigate to: http://localhost:3000**

### 2.2 Dependencies
List of Dependencies with Versions
Ruby Gems:
Rails: >= 6.0
Devise: User authentication
RSpec: Testing framework
Faker: Data seeding
PG: PostgreSQL adapter
Additional gems listed in the Gemfile.
Node.js Packages:
Webpack: Asset bundler
Any other frontend dependencies listed in the package.json.
Instructions for Installing Dependencies
Use Bundler to install Ruby dependencies:
bundle install
Use Yarn or npm to install JavaScript dependencies:
yarn install



## 3. Running the Tests
### 3.1 Test Setup
Instructions to Run the Tests:
Ensure the application is set up and all dependencies are installed (refer to the Getting Started section).
Open a terminal in the project directory.
Run the following command to execute the test suite:
bundle exec rspec
Required Configurations or Dependencies for Tests:
RSpec:
The project uses RSpec as the testing framework. Ensure it is installed by running:
bundle install

Database Setup for Testing:
The test environment requires a separate database. Ensure the test database is created and migrated:

RAILS_ENV=test rails db:create
RAILS_ENV=test rails db:migrate
### 3.2 Test Metrics
Test Coverage:
The project aims for a minimum of 90% test coverage to ensure robustness and reliability.
Generating Coverage Reports:
SimpleCov Integration:
The project uses SimpleCov for test coverage analysis.
Ensure the SimpleCov gem is included in the Gemfile under the test group
Run the Tests with Coverage:
Execute the test suite as usual:
bundle exec rspec
View the Coverage Report:
After running the tests, the coverage report will be generated in the coverage/ directory.
Open the index.html file in a web browser to view detailed coverage metrics.

## 4. Deployment Guide
1. Log in to Heroku: heroku login

2. Create App:
   ```bash
   heroku create <app-name>
   ```

3. Provison postgres for your app:
   ```bash
   heroku addons:create heroku-postgresql:essential-0 -a <app-name>
   ```

4. Set the RAILS_MASTER_KEY environment variable:
   ```bash
   heroku config:set RAILS_MASTER_KEY=`cat config/master.key`
   ```

5. Push code to Heroku:
   ```bash
   git push heroku main
   ```

6. To add users to the app (i.e. professors):
   ```bash
   heroku run rails console -a <app-name>
   ```

   Then you can add the user by following command:
   ```ruby
   User.create(email: "netid@tamu.edu",name: "First Last", uin: "123006789")
   ```






