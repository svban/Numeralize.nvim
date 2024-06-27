import sys

from num2words import num2words


def convert_number_to_words(number, conversion_type):
    if conversion_type == "o":
        return num2words(number, to="ordinal")
    else:
        return num2words(number)


if __name__ == "__main__":
    number = int(sys.argv[1])
    conversion_type = sys.argv[2]  # 'o' for ordinal, 'c' for cardinal
    print(convert_number_to_words(number, conversion_type))
