package com.ceburilo.server.ceburilo.model;

import javax.persistence.*;
import java.math.BigInteger;

/**
 * Created by james on 03/06/2017.
 */

@Entity
@Table(name="stations", schema="public")
public class Station {

    @Id
    @Column(name="uid")
    private long uid;

    @Column(name="x")
    private Double x;

    @Column(name="y")
    private Double y;

    @Column(name="name")
    private String name;

    public long getUid() {
        return uid;
    }

    public void setUid(long uid) {
        this.uid = uid;
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
