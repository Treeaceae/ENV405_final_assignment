# Generate binary data
binary_data <- data.frame(
  Study = c("ENV405_2016", "ENV405_2017", "ENV405_2018", "ENV405_2019", "ENV405_2020", "ENV405_2021", "ENV405_2022", "ENV405_2023", "ENV405_2024", "ENV405_2025"),
  Passed_QuizGroup = c(23, 45, 67, 34, 56, 28, 39, 61, 44, 52),
  Total_QuizGroup = c(150, 200, 300, 180, 250, 160, 190, 280, 210, 230),
  Passed_NoQuizGroup = c(15, 32, 58, 29, 41, 19, 33, 52, 35, 44),
  Total_NoQuizGroup = c(145, 195, 295, 175, 245, 155, 185, 275, 205, 225)
)

# Generate continuous data
continuous_data <- data.frame(
  Study = c("Smith_2020", "Johnson_2019", "Williams_2021", "Brown_2018", "Davis_2022", "Miller_2017", "Wilson_2019", "Moore_2020", "Taylor_2021", "Anderson_2018"),
  N_Experimental = c(45, 68, 52, 37, 61, 42, 55, 48, 59, 44),
  Mean_Experimental = c(25.3, 18.7, 32.1, 12.4, 28.6, 15.9, 22.7, 19.3, 26.8, 14.2),
  SD_Experimental = c(4.2, 3.8, 5.3, 2.9, 4.8, 3.2, 4.1, 3.5, 4.7, 3.1),
  N_Control = c(43, 65, 50, 35, 59, 40, 53, 46, 57, 42),
  Mean_Control = c(23.1, 16.9, 29.8, 11.2, 26.3, 14.5, 20.8, 17.6, 24.9, 12.8),
  SD_Control = c(4.5, 3.6, 5.1, 2.7, 4.6, 3.0, 3.9, 3.4, 4.5, 2.9)
)

write.csv(binary_data, "binary_data.csv", row.names = FALSE)
write.csv(continuous_data, "continuous_data.csv", row.names = FALSE)