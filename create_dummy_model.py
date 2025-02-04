import xgboost as xgb
import tarfile
import os

# Create a minimal model directory structure
os.makedirs('model', exist_ok=True)

# Create a dummy XGBoost model
dtrain = xgb.DMatrix([[1, 2], [3, 4]], label=[0, 1])
param = {'max_depth': 2, 'eta': 1, 'objective': 'binary:logistic'}
model = xgb.train(param, dtrain, 1)

# Save the model
model.save_model('model/xgboost-model')

# Create tar.gz
with tarfile.open('model.tar.gz', 'w:gz') as tar:
    tar.add('model', arcname='.')