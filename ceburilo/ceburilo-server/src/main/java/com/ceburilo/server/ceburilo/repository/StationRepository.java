package com.ceburilo.server.ceburilo.repository;

import org.springframework.data.repository.CrudRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import com.ceburilo.server.ceburilo.model.Station;

import java.util.List;

/**
 * Created by james on 03/06/2017.
 */
@RepositoryRestResource(collectionResourceRel = "stations", path = "stations")
public interface StationRepository extends CrudRepository<Station, Long> {

}
