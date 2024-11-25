from collections import Counter

def count_predictions(log_file):
    try:
        with open(log_file, "r") as file:
            predictions = [line.strip().split(": ")[1] for line in file]
            counts = Counter(predictions)
            return counts
    except FileNotFoundError:
        print(f"Log file {log_file} not found!")
        return {}

# Count predictions from the log file
log_file = "predictions.log"
class_counts = count_predictions(log_file)

# Print the results
print("Class counts:")
for cls, count in class_counts.items():
    print(f"{cls}: {count}")
