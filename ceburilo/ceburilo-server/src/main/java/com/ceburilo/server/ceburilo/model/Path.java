package com.ceburilo.server.ceburilo.model;


import java.util.ArrayList;
import java.util.List;

/**
 * Created by james on 02/06/2017.
 */

public class Path {

    public Path() {
        points = new ArrayList<>();
    }

    public Path(List<Point> points) {
        this.points = points;
    }

    private List<Point> points;

    public List<Point> getPoints() {
        return points;
    }

    public void setPoints(List<Point> points) {
        this.points = points;
    }

    public void addPoint(Point point) {
        this.points.add(point);
    }
}
