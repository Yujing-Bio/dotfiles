# AI/ML Replication Plan Instructions

For papers flagged as AI/ML, generate a high-level replication architecture plan.

## Structure

### Model Architecture
- What are the key components? (encoder, decoder, attention layers, etc.)
- What is the overall architecture pattern? (transformer, CNN, GNN, hybrid, etc.)
- What are the important architectural decisions and why?

### Training Pipeline
- What is the training objective/loss function?
- What optimization approach is used? (optimizer, learning rate schedule, etc.)
- What are the key training hyperparameters mentioned?
- Are there multiple training stages? (pre-training, fine-tuning, etc.)

### Data Requirements
- What datasets are used?
- What preprocessing or augmentation is applied?
- What are the data scale requirements? (number of samples, compute hours, etc.)
- Are the datasets publicly available?

### Key Design Decisions
- What makes this approach different from prior work?
- What ablation results highlight which components matter most?
- What would you prioritize implementing first to validate the core idea?

## Depth Adjustment

**Brief mode:** List the components, training approach, and data requirements in bullet form (no elaboration).

**Detailed mode:** Full structured analysis as described above.

## Note

This is a high-level architecture plan, not implementation code. The goal is to understand what needs to be built, not to write it.
