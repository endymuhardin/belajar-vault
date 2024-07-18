package com.muhardin.endy.belajar.vault.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.muhardin.endy.belajar.vault.dao.ProdukDao;
import com.muhardin.endy.belajar.vault.entity.Produk;

@RestController
public class ProdukApiController {

    @Autowired private ProdukDao produkDao;

    @GetMapping("/api/produk/")
    public PagedModel<Produk> dataProduk(Pageable page){
        return new PagedModel<>(produkDao.findAll(page));
    }
}
