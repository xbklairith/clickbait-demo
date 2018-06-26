FROM ruby:2.4

RUN bundle config --global frozen 1

WORKDIR /app

COPY . /app
RUN bundle install
RUN gem install rack

# 9292 is default port rack
EXPOSE 9292 

ENV AIRLINE_AUTOCORRECT_URL http://139.162.53.9:8890/autocorrect
ENV AIRLINE_NLU_URL http://139.162.53.9:8899/nlu

CMD [ "bundle", "exec", "rackup", "-o", "0.0.0.0" ]