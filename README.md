# Devices API

Device monitoring and control API.


## Requirements

Devices API is tested against MRI 1.9.3.


## Installation 

```bash
$ git clone git@github.com:lelylan/devices.git && cd devices
$ gem install bundler
$ bundle install 
$ foreman start
```

## Install with docker

#### Badges
Docker image: [lelylanlab/api-proxy](https://hub.docker.com/r/lelylanlab/devices/)

[![](https://images.microbadger.com/badges/version/lelylanlab/devices:latest.svg)](http://microbadger.com/images/lelylanlab/devices:latest "Get your own version badge on microbadger.com")  [![](https://images.microbadger.com/badges/image/lelylanlab/devices:latest.svg)](http://microbadger.com/images/lelylanlab/devices:latest "Get your own image badge on microbadger.com")

### Use docker hub image
```bash
$ docker run -d -it --name api-proxy lelylanlab/devices
```

### Generate local image
```bash
$ docker build --tag=devices .
$ docker run -d -it --name devices devices
```

When installing the service in production set [lelylan environment variables](https://github.com/lelylan/lelylan/blob/master/README.md#production).


## Resources

* [Lelylan Devices API](http://dev.lelylan.com/api#api-devices)


## Contributing

Fork the repo on github and send a pull requests with topic branches. 
Do not forget to provide specs to your contribution.


### Running specs

```bash
$ gem install bundler
$ bundle install 
$ bundle exec guard
```

Press enter to execute all specs.

## Spec guidelines

Follow [betterspecs.org](http://betterspecs.org) guidelines.


## Coding guidelines

Follow [github](https://github.com/styleguide/) guidelines.


## Feedback

Use the [issue tracker](http://github.com/lelylan/devices/issues) for bugs or [stack overflow](http://stackoverflow.com/questions/tagged/lelylan) for questions.
[Mail](mailto:dev@lelylan.com) or [Tweet](http://twitter.com/lelylan) us for any idea that can improve the project.


## Links

* [GIT Repository](http://github.com/lelylan/devices)
* [Lelylan Dev Center](http://dev.lelylan.com)
* [Lelylan Site](http://lelylan.com)


## Authors

[Andrea Reginato](https://www.linkedin.com/in/andreareginato)


## Contributors

Special thanks to [all people](https://github.com/lelylan/devices/graphs/contributors) helping to make the project real.


## Changelog

See [CHANGELOG](https://github.com/lelylan/devices/blob/master/CHANGELOG.md)


## License

Lelylan is licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
