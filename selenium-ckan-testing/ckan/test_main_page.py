# encoding: utf-8
import unittest
from selenium import webdriver


class CKANMainPAge(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Chrome()
        try:
            self.driver.get("http://192.168.33.10")
        except Exception as e:
            print(e.message)

    def tearDown(self):
        self.driver.close()

    def test_main_page_title(self):
        assert "Welcome - CKAN" in self.driver.title

    def test_main_page_text(self):
        elem = self.driver.find_element_by_class_name("page-heading")
        assert "Welcome to CKAN" in elem.text


if __name__ == "__main__":
    unittest.main()
