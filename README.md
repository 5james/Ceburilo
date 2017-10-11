# Ceburilo
University project for Spatial Databases subject.

Application searches for all available **NextBike** (Veturilo) stations and determines the route (navigate) from Start Point to End Point. It will search for nearest NextBike station and then calculate which stations user should visit. Time to travel between one and the other station cannot be longer than 20 minutes (in order not to pay extra). Algorithm in database calculates the best route to achieve this task.

Project uses **Postgres** database.
System made in **client-server** architecture:
 - Server made in **Spring** (mvn) - facilitate database's records and function (calculating best route).
 - Client (Front-end) made in **iOS app** - uses GLMap (OpenSteetMap map).

Database uses **OpenStreetMap** to download spatial map of Warsaw. All required SQL scripts to create database are included in folder ''sql''. But firstly one should download .osm file from OpenStreetMap (Warsaw) and import it in Postgres.

Main tasks of database:
 - store Warsaw spatial database
 - store NextBike (Veturilo) stations
 - **calculate best possible route between next stations (algorithm to find best sequence of stations)**