library(tidyverse)
library(frequency)
library(htmltools)
library(dplyr)
library(janitor)
library(POSIXlt)

e=readRDS("NETcodering")


#tabellen type nieuws op geaggregeerd niveau

e |> tabyl(type)

sfTabel <- filter(e, type=="SF") |>
  filter(object01=="party") |>
  group_by(object)|>
  summarize(freq=sqrt(n()), qual=mean(quality)) |>
  mutate(sffq=freq*qual) |>
  arrange(freq) |>
  mutate(object = ordered(object, levels = unique(object)))

ggplot(data=sfTabel, aes(fill=sffq, x="", y=object)) +
  geom_tile() +
  ggthemes::theme_hc() + ylab(NULL) + xlab("party") + 
  scale_fill_gradient2(low=scales::muted("red"), mid="#F2F2F2",midpoint=0, high=scales::muted("green"), guide=F) 

reaTabel <- filter(e, type=="REA") |>
  filter(object01=="issue") |>
  filter(object !="issue") |>
  group_by(object)|>
  summarize(freq=sqrt(n()), qual=mean(quality)) |>
  mutate(reafq=freq*qual) |>
  arrange(freq) |>
  mutate(object = ordered(object, levels = unique(object)))

ggplot(data=reaTabel, aes(fill=reafq, x="", y=object)) +
  geom_tile() +
  ggthemes::theme_hc() + ylab(NULL) + xlab("issue") + 
  scale_fill_gradient2(low=scales::muted("red"), mid="#F2F2F2",midpoint=0, high=scales::muted("green"), guide=F) 

ccTabel <- filter(e, type=="CC") |> 
  filter(subject01=="party")|>
  filter(object01=="party") |>
  select(subject, object, quality) |>
  arrange(subject, object) |>
  group_by(subject, object) |>
  summarize(freq=sqrt(n()), qual=mean(quality)) |>
  mutate(ccfq=freq*qual) |>
  mutate(ccfq=round(ccfq, digits=1))

ggplot(data=ccTabel, aes(x=subject, y=object, fill=ccfq)) +
  geom_tile() +
  geom_text(aes(label = ccfq), color ="black", size=2) +
  coord_fixed() +
  ggthemes::theme_hc() + ylab("object") + xlab("subject") + 
  scale_fill_gradient2(low=scales::muted("red"), mid="#F2F2F2",midpoint=0, high=scales::muted("green"), guide=F) +
  theme(axis.text.x = element_text(angle = 45, vjust=1, hjust=1))

ipTabel <- filter(e, type=="IP") |> 
  filter(subject01=="party")|>
  filter(object01=="issue") |>
  select(subject, object, quality) |>
  arrange(subject, object) |>
  group_by(subject, object) |>
  summarize(freq=sqrt(n()), qual=mean(quality)) |>
  mutate(ipfq=freq*qual) |>
  mutate(ipfq=round(ipfq, digits=1))

ggplot(data=ipTabel, aes(x=subject, y=object, fill=ipfq)) +
  geom_tile() +
  geom_text(aes(label = ipfq), color ="black", size=2) +
  coord_fixed() +
  coord_flip() +
  ggthemes::theme_hc() + ylab("object") + xlab("subject") + 
  scale_fill_gradient2(low=scales::muted("red"), mid="#F2F2F2",midpoint=0, high=scales::muted("green"), guide=F) +
  theme(axis.text.x = element_text(angle = 45, vjust=1, hjust=1))

#=====


KsfTabel <- filter(e, type=="SF") |>
  filter(object01=="party") |>
  mutate (date=as.Date(date,"%d-%m-%Y"))|>
  select(date, publisher, object, quality) |>
  arrange(publisher, object, date) |>
  group_by(publisher, object, date) |>
  summarize(freq=sqrt(n()), qual=mean(quality)) |>
  mutate(sffq=freq*qual)

KreaTabel <- filter(e, type=="REA") |>
  filter(object01=="issue") |>
  mutate (date=as.Date(date,"%d-%m-%Y"))|>
  select(date, publisher, object, quality) |>
  arrange(publisher, object, date) |>
  group_by(publisher, object, date) |>