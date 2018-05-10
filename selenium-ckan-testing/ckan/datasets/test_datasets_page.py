import unittest
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By


class TestsDatasetPage(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Chrome()
        try:
            self.driver.get("http://192.168.33.10/dataset")
        except Exception as e:
            print(e.message)

    def tearDown(self):
        self.driver.close()

    def test_dataset_landing_page(self):
        assert "Datasets" in self.driver.title

    def test_dataset_results_found(self):
        results = self.driver.find_element_by_xpath('//*[@id="dataset-search-form"]/h2')
        assert "2 datasets found" in results.text
