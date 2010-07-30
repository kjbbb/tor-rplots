library("RPostgreSQL")
library("ggplot2")

db = "tordir"
dbuser = "ernie"
dbpassword= ""

plot_bandwidth_versions <- function() {

  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select sum(d.bandwidthavg) as bandwidthsum, ",
    "    substring(d.platform, 5, 5) as version ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where date(s.validafter) = '2010-03-01' ",
    "group by substring(d.platform, 5, 5)")

  rs <- dbSendQuery(con, q)
  bandwidth <- fetch(rs,n=-1)

  ggplot(bandwidth, aes(x="", y=bandwidthsum, fill=version)) +
    geom_bar(position="dodge") +
    scale_y_continuous(name="") +
    scale_x_discrete(name="Version") +
    scale_colour_brewer(name="Version") +
    opts(title="Bandwidth distribution per version")

  ggsave(filename="png/bandwidth-versions-bargraph.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_bandwidth_platforms <- function()  {

  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste (" select sum(d.bandwidthavg) as bandwidthsum, ",
    "      (case when platform like '%Windows%' then 'Windows' ",
    "      when platform like '%Linux%' then 'Linux' ",
    "      when platform like '%FreeBSD%' then 'FreeBSD' ",
    "      when platform like '%Darwin%' then 'Darwin' else 'other' end) as platform ",
    " from descriptor d ",
    " join statusentry s on d.descriptor=s.descriptor ",
    " where bandwidthavg is not null ",
    "     and date(s.validafter) >= '2010-02-01' ",
    " group by (case when platform like '%Windows%' then 'Windows' ",
    "      when platform like '%Linux%' then 'Linux' ",
    "      when platform like '%FreeBSD%' then 'FreeBSD' ",
    "      when platform like '%Darwin%' then 'Darwin' else 'other' end)")

  rs <- dbSendQuery(con, q)
  bandwidth <- fetch(rs,n=-1)

  ggplot(bandwidth, aes(x="", y=bandwidthsum, fill=platform)) +
    geom_bar() +
    scale_y_continuous(name="") +
    scale_x_discrete(name="") +
    scale_colour_brewer(name="Platform") +
    coord_polar("y") +
    opts(title="Bandwidth distribution per platform")

  ggsave(filename="png/bandwidth-platforms-piechart.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)

}

plot_bandwidth_guardexit <- function() {
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, user=dbuser, password=dbpassword, dbname=db)

  q <- paste("select sum(d.bandwidthavg) as bandwidthsum, ",
    "    (case when isexit=true then 't' else 'f' end) || ",
    "    (case when isguard=true then 't' else 'f' end) as guardexit ",
    "from descriptor d ",
    "join statusentry s on d.descriptor=s.descriptor ",
    "where d.bandwidthavg is not null ",
    "    and date(s.validafter) >= '2010-02-01' ",
    "    and date(s.validafter) <= '2010-03-01' ",
    "group by (case when isexit=true then 't' else 'f' end) || ",
    "    (case when isguard=true then 't' else 'f' end) ")

  rs <- dbSendQuery(con, q)
  bandwidth <- fetch(rs,n=-1)

  ggplot(bandwidth, aes(x="", y=bandwidthsum, fill=guardexit)) +
    geom_bar() +
    scale_y_continuous(name="") +
    scale_x_discrete(name="") +
    scale_colour_brewer(name="Guard/exit flags") +
    coord_polar("y") +
    opts(title="Bandwidth distribution per guard/exit/relay flags")

  ggsave(filename="png/bandwidth-guardexit-piechart.png", width=8, height=5, dpi=72)

  #Close database connection
  dbDisconnect(con)
  dbUnloadDriver(drv)
}

plot_bandwidth_versions()
plot_bandwidth_platforms()
plot_bandwidth_guardexit()
