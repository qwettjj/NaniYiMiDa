package com.java.NaniYiMiDa.repository;

import com.java.NaniYiMiDa.po.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    User findByPhoneNumber(String phoneNumber);
    User findByPhoneNumberAndPassword(String phoneNumber, String password);
    User findByUserName(String userName);
}
