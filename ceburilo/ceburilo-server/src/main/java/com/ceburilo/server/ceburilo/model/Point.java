package com.ceburilo.server.ceburilo.model;

/**
 * Created by james on 02/06/2017.
 */
public class Point {


    public Point() {
    }

    public Point(Double x, Double y, Integer seq) {
        this.x = x;
        this.y = y;
        this.seq = seq;
    }

    private Double x;
    private Double y;
    private Integer seq;

    public Integer getSeq() {
        return seq;
    }

    public void setSeq(Integer seq) {
        this.seq = seq;
    }

    public Double getX() {
        return x;
    }

    public void setX(Double x) {
        this.x = x;
    }

    public Double getY() {
        return y;
    }

    public void setY(Double y) {
        this.y = y;
    }

}
