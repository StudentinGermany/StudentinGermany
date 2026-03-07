import random
import string
import time
from datetime import datetime, timedelta
from pathlib import Path

# Configuration
OUTPUT_DIR = Path("mock_email_data")
START_DATE = datetime(2025, 1, 1, 9, 0, 0)


class EmailDataGenerator:
    """
    Simulates a stream of incoming emails related to transaction deals.
    Generates metadata and dummy HTML body content.
    """

    def __init__(self, start_time: datetime):
        self.clock = start_time
        self.domains = ["example.com", "testmail.net", "dummy.org", "sample.co"]

        # Ensure output directory exists
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    def _generate_random_string(self, length: int) -> str:
        """Helper to generate random lowercase strings."""
        return ''.join(random.choices(string.ascii_lowercase, k=length))

    def _generate_html_content(self, element_count=8) -> str:
        """Constructs a random HTML body with basic structure."""
        body_parts = [
            '<!DOCTYPE html>', '<html>', '<head><style>body{font-family: sans-serif;}</style></head>',
            '<body>', f'<h1>Message Ref: {self._generate_random_string(6).upper()}</h1>'
        ]

        tags = ['p', 'div', 'blockquote', 'h3', 'span']

        for _ in range(element_count):
            tag = random.choice(tags)
            word_count = random.randint(4, 12)
            sentence = ' '.join(self._generate_random_string(random.randint(3, 8)) for _ in range(word_count))

            if tag == 'p':
                body_parts.append(f'<p>{sentence}.</p>')
            elif tag == 'blockquote':
                body_parts.append(f'<blockquote>{sentence}</blockquote>')
            else:
                body_parts.append(f'<{tag}>{sentence}</{tag}>')

        body_parts.extend(['</body>', '</html>'])
        return '\n'.join(body_parts)

    def produce_record(self) -> dict:
        """
        Generates a single data record and saves the corresponding HTML file.
        Returns a dictionary representing the database row/API response.
        """
        # 1. Update internal clock (random increment between 1s and 1 hour)
        self.clock += timedelta(seconds=random.randint(1, 3600))

        # 2. Determine Deal Status
        is_deal_closed = random.choice([True, False])

        # 3. Generate ID based on status
        if is_deal_closed:
            # Format: TRX-8Digits (e.g., TRX-94837210)
            deal_id = f"TRX-{''.join(random.choices(string.digits, k=8))}"
        else:
            deal_id = None

        # 4. Generate Email Metadata
        user = self._generate_random_string(8)
        domain = random.choice(self.domains)
        sender = f"{user}@{domain}"

        subject_words = [self._generate_random_string(random.randint(4, 7)) for _ in range(4)]
        subject = " ".join(subject_words).title()

        # 5. Handle File Output
        filename = f"{int(self.clock.timestamp())}_{random.randint(100, 999)}.html"
        file_path = OUTPUT_DIR / filename

        # Write the HTML file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(self._generate_html_content())

        # Return structured data
        # """
        # x0: bool deal-taken (0: not taken / 1: taken)
        # x1: deal number
        # x2: email sent time
        # x3: sender address
        # x4: title
        # x5: html body path
        # """
        return {
            "status_closed": is_deal_closed,  # x0
            "deal_reference": deal_id,  # x1
            "timestamp": self.clock.isoformat(),  # x2
            "sender_email": sender,  # x3
            "email_subject": subject,  # x4
            "local_path": str(file_path)  # x5
        }


def run_simulation():
    # Ensure directory exists
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    stream = EmailDataGenerator(start_time=START_DATE)

    print(f"Starting simulation. Saving to {OUTPUT_DIR}...")
    print("Press Ctrl+C to stop.\n")

    try:
        while True:
            data = stream.produce_record()
            print(f"[{data['timestamp']}] New Email: {data['sender_email']} | Deal: {data['deal_reference']}")
            # print(data) # Uncomment to see full dictionary
            time.sleep(1.0)

    except KeyboardInterrupt:
        print("\nSimulation stopped by user.")


if __name__ == "__main__":
    run_simulation()