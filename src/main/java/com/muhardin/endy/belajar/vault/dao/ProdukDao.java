package com.muhardin.endy.belajar.vault.dao;

import org.springframework.data.jpa.repository.JpaRepository;

import com.muhardin.endy.belajar.vault.entity.Produk;

public interface ProdukDao extends JpaRepository <Produk, Long>{
    
}
