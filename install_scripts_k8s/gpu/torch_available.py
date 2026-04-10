import torch
import torch.nn as nn

if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)} is available.")
else:
    print("No GPU available. Training will run on CPU.")


# Example model
class Generate(nn.Module):
    def __init__(self):
        super(Generate, self).__init__()
        self.gen = nn.Sequential(
            nn.Linear(5,1),
            nn.Sigmoid()
        )

    def forward(self, x):
        return self.gen(x)

model = Generate() # Initialize the model
model.to('cuda') # Move the model to the GPU

# Create input data inside GPU
input_data = torch.randn(16, 5, device='cuda:0')
output = model(input_data) # Forward pass on theGP
print(output)