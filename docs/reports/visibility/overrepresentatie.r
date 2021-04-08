library(here)
library(tidyverse)


theme_nrc = function(...) {
  ggthemes::theme_hc(...) + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1), 
          axis.title.x=element_blank(), 
          axis.title.y=element_blank(),
          strip.background = element_rect(fill="white"))
}

colors = c(FvD="black", PVV="darkblue", VVD="blue", CDA="yellow", D66="lightgreen", PvdA="red", GL="green", SP="darkred", CU="Orange", PvdD="darkgreen", JA21="purple", Other="purple")

hits = read_csv(here("data/intermediate/amcat_hits.csv")) %>% 
  filter(publisher != "Nieuwsuur", publisher != "NOS liveblog") %>%
  mutate(week = lubridate::floor_date(date, "week", week_start=4)) %>%
  filter(date > "2021-01-06") 

meta = read_csv(here("data/intermediate/amcat_meta.csv")) %>% filter(publisher != "Nieuwsuur", publisher != "NOS liveblog") %>%
  filter(publisher != "Nieuwsuur", publisher != "NOS liveblog") %>%
  mutate(week = lubridate::floor_date(date, "week", week_start=4)) %>%
  filter(date > "2021-01-06") 

a = hits %>% filter(cat == "actor") %>% rename(party=subcat) %>% 
  mutate(week = lubridate::floor_date(date, "week", week_start=4)) %>%
  filter(date > "2021-01-06") 

tv = a %>% filter(mtype == "TV") %>% select(mtype, party, publisher, date) %>% unique() %>%
 group_by(mtype, party, publisher) %>% summarize(n=n()) 
other = a %>% filter(mtype != "TV") %>% select(mtype, publisher, party, id) %>% unique() %>% 
  group_by(mtype, publisher, party) %>% summarize(n=n())


gasten = read_csv("~/Downloads/gasten_20210317.csv") %>% 
  filter(date > "2021-01-01", !is.na(partij)) %>% 
  select(party=partij, date, show) %>% 
  mutate(party=case_when(tolower(party) == "groenlinks" ~ "GL",
                         party == "ChristenUnie" ~ "CU",
                         party == "50PLUS" ~ "50Plus",
                         party == "volt" ~ "Volt",
                         T ~ party)) %>% 
  group_by(show, party) %>% summarize(n=n())%>% add_column(mtype="guest")

zetels = read_csv("~/Documents/zetels.csv") %>% 
  select(party=partij, regering, rechts, tk2017, polls=`2021-02-17`) %>% 
  replace_na(list(polls=0)) %>% 
  mutate(tk2017p=tk2017/sum(tk2017), 
         pollsp=polls/sum(polls),
         party=case_when(party=="50+" ~ "50Plus", 
                         party=="DENK" ~ "Denk",
                         party == "VOLT" ~ "Volt",
                         T ~ party))
  
https://vu-live.zoom.us/j/98572542426?pwd=WGZzcFFDUFF5NUN6SitxNHlCQzZlZz09 = bind_rows(tv, other, gasten)

d = visibility %>% select(-n) %>% pivot_wider(names_from=mtype, values_from=perc) %>% inner_join(zetels) 

m = glm(TV ~ tk2017 + polls + regering, family=binomial, data=d)
m2 = glm(TV ~ tk2017 + polls + regering, family=binomial, data=d, weights=rep(1000,15))
m2 = glm(TV ~ tk2017 + polls + regering + rechts, family=binomial, data=d, weights=rep(1000,15))
summary(m)
summary(m2)
glm(Newspapers ~ tk2017 + polls + regering + rechts, family=binomial, data=d, weights=rep(1000,15)) %>% summary()

m.news = glm(Newspapers ~ tk2017 + polls + regering, family=binomial, data=d)

d %>% select(party, TV) %>%
  mutate(resid.tv = resid(m), 
         predict.tv = predict(m, d),
         predict.tv.perc = exp(predict.tv) / sum(exp(predict.tv)),
         logodds = log(TV), 
         resid2=logodds - predict.tv) %>% 
  ggplot(aes(y=party)) + geom_col(aes(x=TV)) + geom_col(aes(x=predict.tv.perc), width=.5, fill="blue")

summary(glm(TV ~ tk2017 + polls + regering + rechts, family=binomial, data=d))

ggplot(d, aes(y=fct_reorder(party, pollsp))) + geom_col(aes(x=pollsp)) + geom_col(aes(x=Newspapers), width=.5, fill="blue") + 
  ggtitle("Visibility on TV (blue) compared to standing in polls")+ 
  theme_nrc() + xlim(0, 0.26)

ggplot(d, aes(y=fct_reorder(party, pollsp))) + geom_col(aes(x=tk2017p)) + geom_col(aes(x=Newspapers), width=.5, fill="blue") + 
  ggtitle("Visibility on TV (blue) compared to seats in parliament")+ 
  theme_nrc() + xlim(0, 0.26)


d %>% select(party, tk2017p, pollsp, Newspapers) %>%
  mutate(resid = resid(m.news), 
         predict = predict(m.news, d),
         predict.perc = exp(predict) / sum(exp(predict))
  ) %>% 
  ggplot(aes(y=fct_reorder(party, pollsp))) + geom_col(aes(x=predict.perc)) + geom_col(aes(x=Newspapers), width=.5, fill="blue") + 
  ggtitle("Visibility on TV (blue) compared to model") + 
  theme_nrc() + xlim(0, 0.26)



ggplot(d, aes(y=fct_reorder(party, pollsp))) + geom_col(aes(x=pollsp)) + geom_col(aes(x=guest), width=.5, fill="blue") + 
  ggtitle("Guest on talkshow (blue) compared to standing in polls")+ 
  theme_nrc() + xlim(0, 0.26)


ggplot(d, aes(y=fct_reorder(party, pollsp))) + 
  geom_col(aes(x=tk2017p), fill="lightgrey") + 
  geom_col(aes(x=pollsp), width=.6, fill="darkgrey") + 
  geom_col(aes(x=guest), width=.33, fill="blue") +
  
  ggtitle("Guest on talkshow (blue) compared to seats in parliament (dark grey) and polls (light grey)")+ 
  theme_nrc() + xlim(0, 0.26)

ggplot(d, aes(y=fct_reorder(party, pollsp))) + 
  geom_col(aes(x=tk2017p), fill="lightgrey") + 
  geom_col(aes(x=pollsp), width=.6, fill="darkgrey") + 
  geom_col(aes(x=TV), width=.33, fill="blue") +
  
  ggtitle("Appearances on TV", "Compared to seats in parliament (light grey) and polls (dark grey)")+ 
  theme_nrc() + xlim(0, 0.26)
