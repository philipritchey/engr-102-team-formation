# team-formation

Code climate link
https://codeclimate.com/github/phanijyothi11-tamu/team-formation

Deployed heroku app
https://teamformation-c5eaebc1d53b.herokuapp.com/

1. Introduction
The "Team Formation" project is a web application designed to facilitate the users in creation of balanced and effective teams for academic projects. Developed using Ruby on Rails, this application allows users to input student data and specify criteria for team composition, such as skill sets and diversity factors. The system then processes this information to generate optimal team assignments that align with the defined parameters. By automating the team formation process, the application aims to enhance collaboration and project outcomes in educational settings.

2. Getting Started and Running Locally
2.1 Setup
Prerequisites
Required Tools:
Ruby (version >= 2.7)
Ruby on Rails (version >= 6.0)
Git
PostgreSQL (version >= 12)
Node.js (version >= 12) and npm/yarn
Bundler (Ruby gem for dependency management)
A terminal/command line interface (CLI)
Software:
A code editor such as Visual Studio Code, Atom, or RubyMine.
A web browser for testing (Google Chrome recommended).
Platform:
Compatible with Linux, macOS, or Windows (with WSL2 recommended for Windows users).





Step-by-Step Instructions to Set Up the Development Environment
Clone the Repository
git clone https://github.com/phanijyothi11-tamu/team-formation.git
cd team-formation
Install Ruby Version: Ensure the Ruby version specified in the .ruby-version file is installed
rbenv install $(cat .ruby-version) 
rbenv local $(cat .ruby-version)
Install Bundler: Install Bundler to manage Ruby dependencies
gem install bundler
Install Project Dependencies: Use Bundler to install Ruby dependencies
bundle install
Install JavaScript Dependencies: Install JavaScript dependencies using npm or yarn
yarn install
Setup the Database: Create, migrate, and seed the database
rails db:create
rails db:migrate
rails db:seed
Add the master.key File: To run the application locally and add a user, create a file named master.key in the config folder and add the following line:
bce3caa08d1af07d574188a55ca6d392
Run the Server: Start the Rails server
rails server
Access the Application: Open your web browser and navigate to:
http://localhost:3000

2.2 Dependencies
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



3. Running the Tests
3.1 Test Setup
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
3.2 Test Metrics
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
5. Deployment Guide
1.Log in to Heroku: heroku login

2.Create App: heroku create <app-name>

3.Login in to your heroku in browser -> Open the application you just created -> Navigate to Resources -> Search for Heroku Postgres -> Add that on to the application.

4.Same page navigate to settings.
   
   Click on Reveal Config Vars and add below 

   KEY                                 
   GOOGLE_CLIENT_ID 
    
   VALUE 
   765932404922-vvd8svdheovq1kf1u4hkrof6d0a4o04g.apps.googleusercontent.com

   KEY
   GOOGLE_CLIENT_SECRET

   VALUE
   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
          

3.Add a Heroku Git remote: git remote add heroku https://git.heroku.com/<app-name>.git

4. Since local and production differ in storing secrets we need to add GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET while deploying.

-> Open the omniauth.rb and replace below line 

provider :google_oauth2, google_credentials[:client_id], google_credentials[:client_secret],



With

provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],

The commit the changes
git add .
git commit -m “google client details”
git push heroku main
NOTE THAT : THE APP URL ALSO NEED TO BE AUTHORIZED BY THE GOOGLE CREDENTIALS HOLDER -> RIGHT NOW CONTACT saijaideepreddymure@tamu.edu AS HE IS THE OWNER.
If you want to deploy in your own heroku app create an account and in that add restrictions to tamu domain an add the link credentials->Authorized redirect URIs here which looks like https://teamformation-c5eaebc1d53b.herokuapp.com/auth/google_oauth2/callback.
App is deployed at this stage

5. heroku run rails db:migrate 

In case you encounter an error here:

Remove this line     remove_column :users, :name, :string from db/migrate/20241003222758_modify_users_table1.rb

And commit and deploy again -> then run heroku run rails db:migrate

6. Once we add users we need to be able to access the app, to do that:
To run application we need to add the user details (so that they can login) which can be done by creating user.
In the terminal, type the command  “heroku run rails console -a appname”
Then you can add the user by following command:
User.create(email: "saijaideepreddymure@tamu.edu",name: "JaideepReddy", uin: "12345")



6. Contact Information
For any questions, support, or feedback related to the "Team Formation" project, please feel free to reach out to the team members:
Name
Email ID
Hitha Magadi Vijayanand
hoshi_1996@tamu.edu
Phani Jyothi Kurada
phanijyothi11@tamu.edu
Raja Karthik Vobugari
raju@tamu.edu
Ramya Reddy Gotika
ramyagotika@tamu.edu
Rithika Sapparapu
rithikasapparapu@tamu.edu
Sahithi Duppati
sahithi@tamu.edu
Sai Jaideep Reddy Mure
saijaideepreddymure@tamu.edu
Uday Kumar Reddy Mettukuru
urt23@tamu.edu





