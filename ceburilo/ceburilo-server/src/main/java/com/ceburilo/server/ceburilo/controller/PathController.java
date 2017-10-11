package com.ceburilo.server.ceburilo.controller;

import com.ceburilo.server.ceburilo.model.Path;
import com.ceburilo.server.ceburilo.model.Point;
import org.springframework.web.bind.annotation.*;

import javax.persistence.*;
import java.util.*;

/**
 * Created by james on 03/06/2017.
 */
@RestController
public class PathController {

    @PersistenceContext
    private EntityManager em;

    @RequestMapping("/searchpath")
    public Path path(@RequestParam(value = "x1") Double x1, @RequestParam(value = "y1") Double y1, @RequestParam(value = "x2") Double x2, @RequestParam(value = "y2") Double y2) {

        if (em == null)
            return null;

        try {
            // ﻿findPathCeburilo_astar(arg_x1 double precision, arg_y1 double precision, arg_x2 double precision, arg_y2 double precision)
            StoredProcedureQuery query = this.em.createStoredProcedureQuery("findPathCeburilo_astar");
            query.setHint("org.hibernate.timeout", "360");
            query.registerStoredProcedureParameter("arg_x1", Double.class, ParameterMode.IN);
            query.registerStoredProcedureParameter("arg_y1", Double.class, ParameterMode.IN);
            query.registerStoredProcedureParameter("arg_x2", Double.class, ParameterMode.IN);
            query.registerStoredProcedureParameter("arg_y2", Double.class, ParameterMode.IN);


            query.setParameter("arg_x1", x1);
            query.setParameter("arg_x2", x2);
            query.setParameter("arg_y1", y1);
            query.setParameter("arg_y2", y2);

            query.execute();
            ArrayList<Object[]> results = (ArrayList<Object[]>) query.getResultList();

            Path path = new Path();
            results.forEach((obj) -> path.addPoint(new Point((Double) obj[0], (Double) obj[1], (Integer) obj[2])));
            return path;
        } catch (Exception e) {
            return null;
        }
    }
}
