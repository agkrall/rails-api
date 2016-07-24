# api2
## Getting started
Make sure rvm and ruby are installed. This will likely get you going in that direction:

```
$ curl -sSL https://get.rvm.io | bash -s stable --ruby
$ source ~/.rvm/scripts/rvm

```

## To begin developing on api2:

### Install ruby
When you first change directory into the api2 source, you will be prompted to
install ruby.  Follow the instructions provided.

### Install needed gems
From within the api2 project source

```
$ gem install bundler
$ bundle

```

It's possible that you will get an error compiling the native dependancies for the pg gem.
If this happens, it's because you don't have the required headers or libraries to compile
against.  Run the following and try again:

```
brew install postgresql

```

### Build the database VM
```
$ cd pg-app-dev-vm
$ vagrant up
$ cd ..
$ rake db:migrate
```

## Run all specs
```
$ rspec

```

## Run the rails server locally on default port 3000
```
$ rails s
```

## Run the rails server locally on port 8080
```
$ rails s -p 8080

```

To run using unicorn (multiple processes)
```
$ unicorn -p 8080 -c config/unicorn.rb

```
